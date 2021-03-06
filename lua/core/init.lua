if vim.fn.exists('g:vscode') == 0 then
  require('core.setup')
  require('core.conf')
end

local load_core = function()
  require('core.opts')
  require('core.binds')
  require('core.pack')

  if vim.fn.exists('g:vscode') == 0 then
    require('core.autocmd')
    require('utils.cmd')
    require('keymap')
    require('modules.aesth')
    require('modules.completion')
    require('modules.tools')
    require('modules.lang')
  end
end

load_core()
