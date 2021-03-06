local load_config = require 'utils.funcs'.load_config

if vim.fn.exists('g:vscode') == 0 then
  require('core.setup')
  require('core.conf')
end

local load_core = function()
  require('core.opts')
  require('core.binds')
  require('core.pack')

  if vim.fn.exists('g:vscode') == 0 then
    require('utils.cmd')
    require('core.autocmd')
    require('modules.aesth')
    require('modules.completion')
    require('modules.tools')
    require('keymap')

    -- Plugins
    load_config('plugin.ts', 'stp')
    require('plugin.telescope')
    require('plugin.which-key')
  end
end

load_core()
