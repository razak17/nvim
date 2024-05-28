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

return M
