if vim.fn.has('nvim') then
    require('core.setup')
    require('core.conf')
end

local load_core = function()
    require('core.opts')
    require('core.binds')
    require('core.pack').ensure_plugins()

    if vim.fn.has('nvim') then
        require('core.autocmd')
        require('keymap')

        vim.cmd [[command! PlugCompile lua require('core.pack').compile()]]
        vim.cmd [[command! PlugInstall lua require('core.pack').install()]]
        vim.cmd [[command! PlugUpdate lua require('core.pack').update()]]
        vim.cmd [[command! PlugSync lua require('core.pack').sync()]]
        vim.cmd [[command! PlugClean lua require('core.pack').clean()]]
    end
end

load_core()
