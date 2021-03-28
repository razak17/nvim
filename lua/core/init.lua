local g = vim.g
local G = require 'core.global'

local disable_builtin_plugins = function()
    g["loaded_gzip"] = 1
    g["loaded_tar"] = 1
    g["loaded_tarPlugin"] = 1
    g["loaded_zip"] = 1
    g["loaded_zipPlugin"] = 1
    g["loaded_getscript"] = 1
    g["loaded_getscriptPlugin"] = 1
    g["loaded_vimball"] = 1
    g["loaded_vimballPlugin"] = 1
    g["loaded_matchit"] = 1
    g["loaded_matchparen"] = 1
    g["loaded_2html_plugin"] = 1
    g["loaded_logiPat"] = 1
    g["loaded_rrhelper"] = 1
    g["loaded_netrw"] = 1
    g["loaded_netrwPlugin"] = 1
    g["loaded_netrwSettings"] = 1
    g["loaded_netrwFileHandlers"] = 1
    g["loaded_fzf"] = 1
    g["loaded_skim"] = 1
    g["loaded_tutor_mode_plugin"] = 1
end

local disable_providers = function()
    g["loaded_python_provider"] = 0
    g["loaded_ruby_provider"] = 0
    g["loaded_perl_provider"] = 0
end

local set_host_prog = function()
    if G.isdir(G.python3 .. "bin") then
        g["python3_host_prog"] = G.python3 .. "bin" .. G.path_sep .. "python"
    end

    if G.exists(G.node) then g["node_host_prog"] = G.node end
end

local global_utils = function()
    g["floating_window_winblend"] = 0
    g["floating_window_scaling_factor"] = 0.8
    g["neovim_remote"] = 1
    g["rg_derive_root"] = true
end

local map_leader = function()
    g["mapleader"] = " "
    g["maplocalleader"] = " "
    g["completion_confirm_key"] = ""
end

local load_core = function()
    disable_builtin_plugins()
    disable_providers()
    set_host_prog()
    global_utils()
    map_leader()

    if vim.fn.has('nvim') then require('core.setup') end

    require('core.opts')
    require('core.binds')
    require('core.pack').ensure_plugins()

    if vim.fn.has('nvim') then
        require('core.autocmd')
        require('keymap')

        if vim.fn.filereadable(G.data_dir .. 'lua/_compiled.lua') == 1 then
            require('_compiled')
        end

        vim.cmd [[command! PlugCompile lua require('core.pack').magic_compile()]]
        vim.cmd [[command! PlugInstall lua require('core.pack').install()]]
        vim.cmd [[command! PlugUpdate lua require('core.pack').update()]]
        vim.cmd [[command! PlugSync lua require('core.pack').sync()]]
        vim.cmd [[command! PlugClean lua require('core.pack').clean()]]
        vim.cmd [[autocmd User PackerComplete lua require('core.pack').magic_compile()]]
    end
end

load_core()
