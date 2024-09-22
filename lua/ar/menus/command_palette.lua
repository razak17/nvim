local api, fn, o = vim.api, vim.fn, vim.o
local fmt = string.format
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

  if ft ~= 'sql' and ar.falsy(fn.executable('prettier')) then
    vim.notify('prettier executable was not found!')
    return
  end

  if ft == 'sql' then
    vim.cmd(':%!npx sql-formatter --language postgresql')
  elseif parser[ft] then
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

  table.insert(file_content, '')
  table.insert(file_content, '## 🗃️ Version manager')
  table.insert(file_content, '')
  table.insert(file_content, '- [bob](https://github.com/MordechaiHadad/bob)')
  table.insert(file_content, '')
  table.insert(file_content, '## ✨ GUI')
  table.insert(file_content, '')
  table.insert(file_content, '- [Neovide](https://neovide.dev/)')

  local file, err = io.open(vim.fn.stdpath('config') .. '/PLUGINS.md', 'w')
  if not file then error(err) end
  file:write(table.concat(file_content, '\n'))
  file:close()
  vim.notify('PLUGINS.md generated.')
end

function M.open_file_in_centered_popup()
  local bufnr = api.nvim_win_get_buf(0)
  ar.open_buf_centered_popup(bufnr)
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
  ar.autosave.enable = not ar.autosave.enable
  local status = ar.autosave.enable and 'enabled' or 'disabled'
  vim.notify(fmt('Autosave has been %s', status))
end

function M.toggle_large_file()
  ar.large_file.enable = not ar.large_file.enable
  local status = ar.large_file.enable and 'enabled' or 'disabled'
  vim.notify(fmt('Large file has been %s', status))
end

function M.copy_path(which)
  local setreg = fn.setreg
  if which == 'file_name' then setreg('+', fn.expand('%:t')) end
  if which == 'absolute_path' then setreg('+', fn.expand('%:p')) end
  if which == 'absolute_path_no_file_name' then
    setreg('+', fn.expand('%:p:h'))
  end
  if which == 'home_path' then setreg('+', fn.expand('%:~')) end
end

return M
