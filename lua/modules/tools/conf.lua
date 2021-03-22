local config = {}

function config.far()
    local function conf(key, value)
        vim.g[key] = value
    end

    conf('far#source', 'rgnvim')
    conf('far#window_width', 50)

    -- Use %:p with buffer option only
    conf('far#file_mask_favorites', {
        '%:p', '**/*.*', '**/*.js', '**/*.py', '**/*.lua', '**/*.css',
        '**/*.ts', '**/*.vim', '**/*.cpp', '**/*.c', '**/*.h'
    })
    conf('far#window_min_content_width', 30)
    conf('far#enable_undo', 1)
end

function config.vim_vista()
    vim.g['vista#renderer#enable_icon'] = 1
    vim.g.vista_icon_indent = [["╰─▸ "], ["├─▸ "]]
    vim.g.vista_disable_statusline = 1
    vim.g.vista_default_executive = 'ctags'
    vim.g.vista_echo_cursor_strategy = 'floating_win'
    vim.g.vista_vimwiki_executive = 'markdown'
    vim.g.vista_executive_for = {
        vimwiki = 'markdown',
        pandoc = 'markdown',
        markdown = 'toc',
        typescript = 'nvim_lsp',
        typescriptreact = 'nvim_lsp'
    }
end

function config.tagalong()
    vim.g.tagalong_filetypes = {
        'html', 'xml', 'jsx', 'eruby', 'ejs', 'eco', 'php', 'htmldjango',
        'javascriptreact', 'typescriptreact', 'javascript'
    }
    vim.g.tagalong_verbose = 1
end

return config

