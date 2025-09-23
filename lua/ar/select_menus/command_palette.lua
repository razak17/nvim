local api, fn = vim.api, vim.fn
local fmt = string.format
local utils = require('ar.utils.fs')

local M = {}

function M.format_buf()
  local ft = vim.bo.filetype
  local parser = {
    json = '--parser json',
    javascript = '--parser babel',
    javascriptreact = '--parser babel',
    typescript = '--parser typescript',
    typescriptreact = '--parser typescript',
    html = '--parser html',
    css = '--parser css',
    scss = '--parser scss',
  }
  local biome_ft = {
    'astro',
    'css',
    'graphql',
    'html',
    'javascript',
    'javascriptreact',
    'json',
    'jsonc',
    'svelte',
    'typescript',
    'typescript.tsx',
    'typescriptreact',
    'vue',
  }

  local biome_exists = fn.executable('prettier')
  local prettier_exists = fn.executable('biome')
  local sql_formatter_exists = fn.executable('biome')

  if ft == 'sql' and ar.falsy(sql_formatter_exists) then
    vim.notify('sql_formatter_exists executable was not found!')
    return
  end

  if ft ~= 'sql' and ar.falsy(prettier_exists or biome_exists) then
    vim.notify('biome or prettier executable was not found!')
    return
  end

  if sql_formatter_exists and ft == 'sql' then
    vim.cmd(':%!sql-formatter --language postgresql')
    return
  end

  if biome_exists and vim.tbl_contains(biome_ft, ft) then
    local path = fn.expand('%')
    vim.cmd(fmt(':!biome format --write "%s"', path))
  elseif prettier_exists and parser[ft] then
    vim.cmd(':%!prettier ' .. parser[ft])
  else
    print('No LSP and unhandled filetype ' .. ft)
  end
end

function M.generate_plugins()
  if not ar.plugin_available('lazy.nvim') then return end
  local plugins = require('lazy.core.config').plugins
  local file_content = {
    '## 💤 Plugin manager',
    '',
    '- [lazy.nvim](https://github.com/folke/lazy.nvim)',
    '',
    '## 🔌 Plugins',
    '',
  }
  local plugins_md = {}
  for plugin, spec in pairs(plugins) do
    if spec.url then
      table.insert(
        plugins_md,
        ('- [%s](%s)'):format(plugin, spec.url:gsub('%.git$', ''))
      )
    end
  end
  table.sort(plugins_md, function(a, b) return a:lower() < b:lower() end)

  for _, p in ipairs(plugins_md) do
    table.insert(file_content, p)
  end

  local file, err = io.open(fn.stdpath('config') .. '/PLUGINS.md', 'w')
  if not file then error(err) end
  file:write(table.concat(file_content, '\n'))
  file:close()
  vim.notify('PLUGINS.md generated.')
end

function M.open_file_in_centered_popup()
  local bufnr = api.nvim_win_get_buf(0)
  ar.open_buf_centered_popup(bufnr)
end

function M.generate_plugin_modules()
  local plugin_dir = fn.stdpath('config') .. '/lua/ar/plugins'
  local files = {}
  local ok, scan = pcall(require, 'plenary.scandir')
  if ok then
    files = scan.scan_dir(plugin_dir, { depth = 1, add_dirs = false })
  else
    -- fallback to vim.loop
    local luv = vim.loop
    local handle = luv.fs_scandir(plugin_dir)
    if handle then
      while true do
        local name, t = luv.fs_scandir_next(handle)
        if not name then break end
        if t == 'file' then table.insert(files, plugin_dir .. '/' .. name) end
      end
    end
  end

  local file_names = {}
  for _, f in ipairs(files) do
    local fname = f:match('([^/]+)$')
    table.insert(file_names, '- ' .. fname)
  end
  table.sort(file_names, function(a, b) return a:lower() < b:lower() end)

  local file_content = {
    '## 📦 Plugin Modules',
    '',
  }
  for _, name in ipairs(file_names) do
    table.insert(file_content, name)
  end

  local out_path = fn.stdpath('config') .. '/PLUGIN_MODULES.md'
  local file, err = io.open(out_path, 'w')
  if not file then error(err) end
  file:write(table.concat(file_content, '\n'))
  file:close()
  vim.notify('PLUGIN_MODULES.md generated.')
end

function M.close_nonvisible_buffers()
  local visible_bufs = {}
  for _, w in pairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(w)
    table.insert(visible_bufs, buf)
  end
  local deleted_count = 0
  for _, b in pairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(b) and not vim.tbl_contains(visible_bufs, b) then
      local force = api.nvim_get_option_value('buftype', { buf = b })
        == 'terminal'
      local ok = pcall(api.nvim_buf_delete, b, { force = force })
      if ok then deleted_count = deleted_count + 1 end
    end
  end
  print('Deleted ' .. deleted_count .. ' buffers')
end

function M.toggle_autosave()
  ar_config.autosave.enable = not ar_config.autosave.enable
  local status = ar_config.autosave.enable and 'enabled' or 'disabled'
  vim.notify(fmt('Autosave has been %s', status))
end

function M.toggle_large_file()
  ar.large_file.enable = not ar.large_file.enable
  local status = ar.large_file.enable and 'enabled' or 'disabled'
  vim.notify(fmt('Large file has been %s', status))
end

function M.copy_path(which)
  local expand_map = {
    file_name = '%:t',
    absolute_path = '%:p',
    absolute_path_no_file_name = '%:p:h',
    home_path = '%:~',
  }

  local expand_arg = expand_map[which]
  if expand_arg then ar.copy_to_clipboard(fn.expand(expand_arg)) end
end

function M.copy_file_path()
  local buf = api.nvim_get_current_buf()
  local name = api.nvim_buf_get_name(buf)
  name = utils.truncpath(name, 40, { cwd = vim.uv.cwd() })
  ar.copy_to_clipboard(name)
end

function M.quick_set_ft()
  local filetypes = {
    'typescript',
    'json',
    'elixir',
    'rust',
    'lua',
    'diff',
    'sh',
    'markdown',
    'html',
    'config',
    'sql',
    'other',
  }
  vim.ui.select(
    filetypes,
    { prompt = 'Pick filetype to switch to' },
    function(choice)
      if choice == 'other' then
        vim.ui.input(
          { prompt = 'Enter filetype', kind = 'center_win' },
          function(word)
            if word ~= nil then vim.cmd('set ft=' .. word) end
          end
        )
      elseif choice ~= nil then
        vim.cmd('set ft=' .. choice)
      end
    end
  )
end

function M.search_code_deps()
  if fn.isdirectory('node_modules') then
    require('telescope').extensions.live_grep_raw.live_grep_raw({
      cwd = 'node_modules',
    })
  else
    vim.cmd(
      [[echohl ErrorMsg | echo "Not handled for this project type" | echohl None]]
    )
  end
end

function M.toggle_file_diff()
  -- remember which is the current window
  local cur_win = api.nvim_get_current_win()

  -- some windows may not be in diff mode, these that I ignore in this function
  -- => check if any window is in diff mode
  local has_diff = false
  local wins = api.nvim_list_wins()
  for _, win in pairs(wins) do
    has_diff = has_diff
      ---@diagnostic disable-next-line: redundant-return-value
      or api.nvim_win_call(win, function() return vim.opt.diff:get() end)
  end

  if has_diff then
    vim.cmd('windo diffoff')
  else
    -- used to do a plain 'windo diffthis', but i want to exclude some window types
    for _, win in pairs(wins) do
      local buf = api.nvim_win_get_buf(win)
      local buf_ft = api.nvim_get_option_value('ft', { buf = buf })
      if
        not vim.tbl_contains({
          'NvimTree',
          'packer',
          'cheat40',
          'OverseerList',
          'aerial',
          'AgitatorTimeMachine',
        }, buf_ft)
      then
        api.nvim_win_call(win, function() vim.cmd('diffthis') end)
      end
    end
    -- restore the original current window
    api.nvim_set_current_win(cur_win)
  end
end

return M
