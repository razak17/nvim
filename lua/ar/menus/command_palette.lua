local api, fn, o = vim.api, vim.fn, vim.o
local M = {}

local should_profile = os.getenv('NVIM_PROFILE')
if should_profile then
  require('profile').instrument_autocmds()
  if should_profile:lower():match('^start') then
    require('profile').start('*')
  else
    require('profile').instrument('*')
  end
end

function M.toggle_profile()
  local prof = require('profile')
  if prof.is_recording() then
    prof.stop()
    vim.ui.input({
      prompt = 'Save profile to:',
      completion = 'file',
      default = 'profile.json',
    }, function(filename)
      if filename then
        prof.export(filename)
        vim.notify(string.format('Wrote %s', filename))
      end
    end)
  else
    prof.start('*')
  end
end

function M.generate_plugins()
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

function M.open_in_centered_popup(path)
  local bufnr = api.nvim_win_get_buf(0)
  if path then
    local lines = fn.readfile(path)
    local buf = api.nvim_create_buf(false, true)
    bufnr = buf
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  local width = math.ceil(o.columns * 0.8)
  local height = math.ceil(o.lines * 0.8)
  local col = math.ceil((o.columns - width) / 2)
  local row = math.ceil((o.lines - height) / 2)

  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    border = 'single',
    style = 'minimal',
  }
  api.nvim_open_win(bufnr, true, opts)
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

return M
