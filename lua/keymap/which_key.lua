local g, api, fn = vim.g, vim.api, vim.fn
local opts = {noremap = true, silent = true}
local config = {}

function config.setup()
    g.which_key_sep = ''
    g.which_key_timeout = 100
    g.which_key_use_floating_win = 0
    g.which_key_display_names = {['<CR>'] = '↵', ['<TAB>'] = '⇆'}

    api.nvim_set_keymap('n', "<leader>", ":<c-u> :WhichKey '<space>'<CR>", opts)
    api.nvim_set_keymap('v', "<leader>", ":<c-u> :WhichKeyVisual '<space>'<CR>",
                        opts)
    fn['which_key#register']('<space>', 'g:which_key_map')

    g.which_key_map = {
        ["="] = "Balance window",
        [";"] = "terminal",
        ["."] = "Open init.vim",
        [","] = "Open init.lua",
        ["/"] = "Comment",
        ["<CR>"] = "Source init.vim",
        d = "Delete current buffer",
        x = "Quit",
        y = "Yank",
        a = {
            name = "+Actions",
            ["/"] = "comment motion default",
            d = "force delete buffer",
            D = "delete all",
            e = "turn off guides",
            E = "delete all buffers and exit",
            f = {
                name = "+Fold",
                l = "under curosr",
                e = "toggle",
                r = "recursive cursor",
                o = "open all",
                x = "close all"
            },
            F = "resize 90%",
            h = "horizontal split",
            n = "no highlight",
            N = "toggle line numbers",
            o = "turn on guides",
            r = "toggle rnvimr",
            R = "toggle relative line numbers",
            s = "save and exit",
            u = "undotreeToggle",
            v = "vertical split",
            V = "select all",
            x = "exit",
            Y = "yank all",
            z = "force exit"
        },
        b = {
            name = "+Buffer",
            n = "move next",
            b = "move previous",
            d = {
                name = "+Delete buffer",
                A = "all",
                h = "to left",
                x = "all except current"
            },

            s = "word"
        },
        c = {
            name = "+Command",
            a = "vertical resize 30",
            h = {name = "+Help", w = "word"},
            f = "nvim-tree find",
            r = "nvim-tree refresh",
            R = "empty registers",
            s = "edit snippet",
            v = "nvim-tree toggle"
        },
        C = {
            name = "+Switch case",
            c = 'shake_case -> camelCase',
            P = 'snake_case -> PascalCase',
            s = 'camelCase/PascalCase -> snake_case'
        },
        e = {
            name = "+Floaterm",
            e = 'toggle',
            l = 'lazygit',
            n = 'node',
            N = 'new terminal',
            p = 'python',
            r = 'ranger'
        },
        f = {
            name = "+Telescope",
            c = {
                name = "+Command",
                A = "autocmds",
                c = "commands",
                b = "buffers",
                e = "planets",
                f = "builtin",
                h = "help",
                H = "history",
                k = "keymaps",
                l = "loclist",
                o = "old files",
                r = "registers",
                T = "treesitter",
                v = "vim options",
                z = "current file fuzzy find"
            },
            e = {name = "+Extensions", e = "packer"},
            f = "find files",
            l = {name = "+Live", g = "grep", w = "current word", e = "prompt"},
            r = {name = "+Config", c = "vimrc"},
            v = {
                name = "+Lsp",
                a = "code action",
                r = "references",
                s = {name = "+Symbols", d = "document", w = "workspace"}
            },
            g = {
                name = '+Git',
                b = "branches",
                c = "commits",
                C = "bcommits",
                f = "files",
                s = "status"
            }
        },
        F = {name = "+Far", f = "replace in File", r = "replace in Project"},
        g = {
            name = "+Git",
            a = 'fetch all',
            b = 'branches',
            A = 'blame',
            c = {name = '+Commit', a = "amend", m = "message"},
            C = 'checkout',
            d = 'diff',
            D = 'diff split',
            h = 'diffget',
            i = 'init',
            k = 'diffget',
            l = 'log',
            e = 'push',
            p = 'poosh',
            P = 'pull',
            r = 'remove',
            s = 'status'
        },
        I = {name = "+Info", c = "check health", e = "treesitter"},
        l = {
            name = "+Lsp utils",
            i = "info",
            f = "format",
            l = "log",
            r = "restart",
            v = "toggle virtual text",
            x = "close quickfix"
        },
        m = {
            name = "+Surround",
            O = "Type => Option<Type>",
            R = "Type => Option<Type, Err>",
            s = "val => Some(val)",
            o = "val => Ok(val)",
            e = "val => Err(val)",
            ['('] = "val => (val)",
            ["'"] = "val => 'val'",
            ['"'] = 'val => "val"'
        },
        P = {
            name = "+Plug",
            c = 'compile',
            C = 'clean',
            i = 'install',
            s = 'sync',
            U = 'update'
        },
        -- r = { name = "+Visual"},
        s = {
            name = "+Tab",
            b = 'previous',
            d = 'close',
            H = 'move left',
            k = 'delete Session',
            K = 'last',
            l = 'next',
            L = 'move right',
            N = 'new'
        },
        S = {
            name = "+Session",
            c = 'close Session',
            d = 'delete Session',
            l = 'load Session',
            s = 'save Session'
        },
        T = {
            name = "+Treesitter",
            m = "scope incremental",
            n = "init selection"
        },
        v = {
            name = "+Code",
            a = "code action",
            D = "preview definition",
            d = {
                name = "+Diagnostics",
                b = "goto previous",
                c = "current line",
                l = "set loc list",
                n = "goto next"
            },
            f = "find the cursor word definition and reference",
            l = {
                name = "+Lsp",
                f = {name = "+find", w = "workspace symbols"},
                h = "show hover doc",
                i = "implementation",
                r = "references",
                R = "rename",
                S = "signature",
                s = {
                    name = "+Symbols",
                    d = "document symbols",
                    w = "workspace symbols"
                },
                t = "type definition"
            },
            w = {name = "+Color", m = "pencils"}
        }
    }

    -- TODO  (get this to work)
    function WhichKeyReverse()
        local key_maps = vim.g.which_key_map
        key_maps.r = {name = "+Line"}
        key_maps.r.e = {name = "+Line"}
        key_maps.r.e.v = "reverse"
        vim.g.which_key_map = key_maps
    end

    _G.WhichKey = {}

    -- TODO  (get this to work)
    WhichKey.SetKeyOnFT = function()
        if vim.fn.mode() == "V" then WhichKeyReverse() end
    end
end

return config
