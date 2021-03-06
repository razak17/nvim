local load_config = require 'utils.funcs'.load_config

if vim.fn.exists('g:vscode') == 0 then
  load_config('core.setup')
  load_config('core.conf')
end

local load_core = function()
  load_config('core.opts')
  load_config('core.binds')
  load_config('core.pack')

  if vim.fn.exists('g:vscode') == 0 then
    load_config('utils.cmd')
    -- load_config('core.autocmd')
    load_config('modules.aesth')
    load_config('modules.completion')
    load_config('modules.tools')
    load_config('keymap')

    -- Plugins
    load_config('plugin.ts', 'stp')
    load_config('plugin.telescope')
    load_config('plugin.which-key')
  end
end

load_core()
