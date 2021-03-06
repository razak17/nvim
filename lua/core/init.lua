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
    require('keymap')
    require('modules.aesth')
    require('modules.completion')
    require('modules.tools')
    require('modules.lang')

    vim.cmd [[command! PlugCompile lua require('core.pack').compile()]]
    vim.cmd [[command! PlugInstall lua require('core.pack').install()]]
    vim.cmd [[command! PlugUpdate lua require('core.pack').update()]]
    vim.cmd [[command! PlugSync lua require('core.pack').sync()]]
    vim.cmd [[command! PlugClean lua require('core.pack').clean()]]
  end
end

load_core()
