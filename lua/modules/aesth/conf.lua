local config = {}

function config.bg()
    vim.g.nvcode_termcolors = 256
    vim.cmd [[ colo onedark ]]

    vim.g.onedark_hide_endofbuffer = 1
    vim.g.onedark_terminal_italics = 1
    vim.g.onedark_termcolors = 256

    vim.cmd [[ autocmd ColorScheme * highlight clear SignColumn ]]
    vim.cmd [[ autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE ]]
    vim.cmd [[ hi ColorColumn ctermbg=lightgrey ]]
    vim.cmd [[ hi LineNr ctermbg=NONE guibg=NONE ]]
    vim.cmd [[ hi Comment cterm=italic ]]
end

function config.galaxyline()
    require('modules.aesth.statusline.eviline')
end

function config.nvim_bufferline()
    require('bufferline').setup {
        options = {
            view = "multiwindow",
            close_icon = ' ',
            buffer_close_icon = '',
            modified_icon = "",
            tab_size = 0,
            enforce_regular_tabs = false,
            diagnostics = "nvim_lsp",
            separator_style = {' ', ' '},
            diagnostics_indicator = function()
                return ''
            end,
            filter = function(buf_num)
                if not vim.t.is_help_tab then return nil end
                return vim.api.nvim_buf_get_option(buf_num, "buftype") == "help"
            end
        }
    }
end

function config.dashboard()
    local home = os.getenv('HOME')
    vim.g.dashboard_preview_command = 'cat'
    vim.g.dashboard_preview_pipeline = 'lolcat'
    vim.g.dashboard_preview_file = home .. '/.config/nvim/static/pokemon.txt'
    vim.g.dashboard_preview_file_height = 14
    vim.g.dashboard_preview_file_width = 80
    vim.g.dashboard_default_executive = 'telescope'
    vim.g.dashboard_custom_section = {
        last_session = {
            description = {
                '  Recently laset session                  SPC s l'
            },
            command = 'SessionLoad'
        },
        find_history = {
            description = {
                '  Recently opened files                   SPC f h'
            },
            command = 'DashboardFindHistory'
        },
        find_file = {
            description = {
                '  Find  File                              SPC f f'
            },
            command = 'DashboardFindFile'
        },
        new_file = {
            description = {
                '  New   File                              SPC t f'
            },
            command = 'DashboardNewFile'
        },
        find_word = {
            description = {
                '  Find  word                              SPC f w'
            },
            command = 'DashboardFindWord'
        },
        find_dotfiles = {
            description = {
                '  Open Personal dotfiles                  SPC f d'
            },
            command = 'Telescope dotfiles path=' .. home .. '/env/nvim'
        }
    }
end

function config.nvim_tree()
    vim.g.nvim_tree_side = 'right'
    vim.g.nvim_tree_ignore = {'.git', 'node_modules', '.cache'}
    vim.g.nvim_tree_quit_on_open = 0
    vim.g.nvim_tree_hide_dotfiles = 0
    vim.g.nvim_tree_follow = 1
    vim.g.nvim_tree_indent_markers = 1
    vim.g.nvim_tree_root_folder_modifier = ':~'
    vim.g.nvim_tree_tab_open = 1
    vim.g.nvim_tree_width_allow_resize = 1
    vim.g.nvim_tree_indent_markers = 1
    vim.g.nvim_tree_show_icons = {git = 1, folders = 1, files = 1}
    vim.g.nvim_tree_bindings = {
        ["l"] = ":lua require'nvim-tree'.on_keypress('edit')<CR>",
        ["s"] = ":lua require'nvim-tree'.on_keypress('vsplit')<CR>",
        ["i"] = ":lua require'nvim-tree'.on_keypress('split')<CR>"
    }
    vim.g.nvim_tree_icons = {
        default = '',
        symlink = '',
        git = {
            unstaged = "✗",
            staged = "✓",
            unmerged = "",
            renamed = "➜",
            untracked = "★"
        }
    }

    vim.cmd [[ highlight NvimTreeFolderIcon guibg=NONE ]]
end

function config.MyColors()
    vim.cmd [[ hi cursorLineNr guifg=#c678dd ]]
    vim.cmd [[ hi netrwDir guifg=#c678dd ]]
    vim.cmd [[ hi qfFileName guifg=#aed75f ]]
    vim.cmd [[ hi TelescopeBorder guifg=#7ec0ee  ]]
    vim.cmd [[ hi FloatermBorder guifg=#7ec0ee ]]
    vim.cmd [[ hi WhichKey guifg=#c678dd ]]
    vim.cmd [[ hi WhichKeySeperator guifg=#aed75f ]]
    vim.cmd [[ hi WhichKeyGroup guifg=#7ec0ee ]]
    vim.cmd [[ hi WhichKeyDesc guifg=#7ec0ee  ]]
end

function config.ColorMyPencils()
    vim.cmd [[ hi ColorColumn guibg=#aeacec ]]
    vim.cmd [[ hi Normal guibg=none ]]
    vim.cmd [[ hi LineNr guifg=#4dd2dc ]]
    vim.cmd [[ hi TelescopeBorder guifg=#aeacec ]]
    vim.cmd [[ hi FloatermBorder guifg= #aeacec ]]
    vim.cmd [[ hi WhichKeyGroup guifg=#4dd2dc ]]
    vim.cmd [[ hi WhichKeyDesc guifg=#4dd2dc  ]]
end

return config

