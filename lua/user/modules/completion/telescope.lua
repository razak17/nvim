return function()
  local telescope_ok, telescope = rvim.safe_require "telescope"
  if not telescope_ok then
    return
  end

  local previewers = require "telescope.previewers"
  local sorters = require "telescope.sorters"
  local actions = require "telescope.actions"
  local themes = require "telescope.themes"

  local function get_border(opts)
    return vim.tbl_deep_extend("force", opts or {}, {
      borderchars = {
        { "─", "│", " ", "│", "╭", "╮", "│", "│" },
        prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
        preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
    })
  end

  ---@param opts table
  ---@return table
  local function dropdown(opts)
    return themes.get_dropdown(get_border(opts))
  end

  local utils = require "user.utils"

  rvim.telescope = {
    setup = {
      defaults = {
        prompt_prefix = " ❯ ",
        selection_caret = " ",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        set_env = { ["TERM"] = vim.env.TERM },
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        file_browser = { hidden = true },
        layout_config = {
          height = 0.9,
          width = 0.9,
          preview_cutoff = 120,
          horizontal = { mirror = false },
          vertical = { mirror = false },
        },
        winblend = 0,
        history = {
          path = rvim.get_cache_dir() .. "/telescope/history.sqlite3",
        },
        file_ignore_patterns = {
          "yarn.lock",
          "target/*",
          "node_modules/*",
          "dist/*",
          ".git/*",
          "venv/*",
          ".venv/*",
          "__pycache__/*",
        },
        path_display = { "smart", "absolute", "truncate" },
        file_sorter = sorters.get_fzy_sorter,
        file_previewer = previewers.vim_buffer_cat.new,
        grep_previewer = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,
        mappings = {
          i = {
            ["<C-w>"] = actions.send_selected_to_qflist,
            ["<c-c>"] = function()
              vim.cmd "stopinsert!"
            end,
            ["<esc>"] = actions.close,
            ["<C-n>"] = actions.move_selection_next,
            ["<C-p>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.cycle_history_next,
            ["<C-k>"] = actions.cycle_history_prev,
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            ["<c-s>"] = actions.select_horizontal,
            ["<CR>"] = actions.select_default + actions.center,
          },
          n = {
            ["<C-n>"] = actions.move_selection_next,
            ["<C-p>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          },
          frecency = {
            db_root = utils.join_paths(rvim.get_cache_dir(), "/telescope"),
            show_scores = true,
            show_unindexed = true,
            ignore_patterns = { "*.git/*", "*/tmp/*" },
            disable_devicons = false,
            workspaces = {
              ["conf"] = "/home/razak/.config",
              ["rvim"] = "/home/razak/.config/rvim",
              ["data"] = "/home/razak/.local/share",
              ["project"] = "/home/razak/personal/workspace/coding",
              ["notes"] = "/home/razak/notes/src",
            },
          },
          ["ui-select"] = {
            themes.get_cursor(get_border {
              layout_config = {
                cursor = {
                  width = 25,
                },
              },
            }),
          },
        },
        pickers = {
          buffers = dropdown {
            sort_mru = true,
            sort_lastused = true,
            show_all_buffers = true,
            ignore_current_buffer = true,
            previewer = false,
            theme = "dropdown",
            mappings = {
              i = { ["<c-x>"] = "delete_buffer" },
              n = { ["<c-x>"] = "delete_buffer" },
            },
          },
          find_files = {
            find_command = { "fd", "--type=file", "--hidden", "--smart-case" },
            hidden = true,
          },
          live_grep = {
            --@usage don't include the filename in the search results
            only_sort_text = true,
            file_ignore_patterns = { ".git/" },
          },
          oldfiles = dropdown(),
          current_buffer_fuzzy_find = dropdown {
            previewer = false,
            shorten_path = false,
          },
          lsp_code_actions = {
            theme = "cursor",
          },
          colorscheme = {
            enable_preview = true,
          },
          git_branches = dropdown(),
          git_bcommits = {
            layout_config = {
              horizontal = {
                preview_width = 0.55,
              },
            },
          },
          git_commits = {
            layout_config = {
              horizontal = {
                preview_width = 0.55,
              },
            },
          },
          reloader = dropdown(),
        },
      },
    },
  }

  telescope.setup(rvim.telescope.setup)

  local plugins = {
    telescope_fzf = "fzf",
    telescope_ui_select = "ui-select",
    telescope_tmux = "tmux",
    telescope_frecency = "frecency",
  }

  for config, plug in pairs(plugins) do
    if rvim.plugin[config].active then
      require("telescope").load_extension(plug)
    end
  end

  local extensions = {
    "grep_string_prompt",
    "bg_selector",
    "nvim_files",
    "dotfiles",
  }

  for _, ext in ipairs(extensions) do
    require("telescope").load_extension(ext)
  end

  require("which-key").register {
    ["<leader>f"] = {
      name = "+Telescope",
      b = { ":Telescope file_browser<cr>", "file browser" },
      f = {
        ":Telescope find_files<cr>",
        "find files",
      },
      c = {
        name = "+Builtin",
        a = { ":Telescope autocommands<cr>", "autocmds" },
        b = { ":Telescope buffers<cr>", "buffers" },
        c = { ":Telescope commands<cr>", "commands" },
        e = { ":Telescope quickfix<cr>", "quickfix" },
        f = { ":Telescope builtin<cr>", "builtin" },
        h = { ":Telescope help_tags<cr>", "help" },
        H = { ":Telescope command_history<cr>", "history" },
        k = { ":Telescope keymaps<cr>", "keymaps" },
        l = { ":Telescope loclist<cr>", "loclist" },
        r = { ":Telescope registers<cr><CR>", "registers" },
        T = { ":Telescope treesitter", "treesitter" },
        v = { ":Telescope vim_options<cr>", "vim options" },
        z = { ":Telescope current_buffer_fuzzy_find<cr>", "current file fuzzy find" },
      },
      d = {
        name = "+Dotfiles",
        b = { ":Telescope dotfiles branches<cr>", "branches" },
        B = { ":Telescope dotfiles bcommits<cr>", "bcommits" },
        c = { ":Telescope dotfiles commits<cr>", "commits" },
        f = { ":Telescope dotfiles git_files<cr>", "git files" },
        s = { ":Telescope dotfiles status<cr>", "status" },
      },
      g = {
        name = "+Git",
        b = { ":Telescope git_branches<cr>", "branches" },
        c = { ":Telescope git_commits<cr>", "commits" },
        C = { ":Telescope git_bcommits<cr>", "bcommits" },
        f = { ":Telescope git_files<cr>", "files" },
        s = { ":Telescope git_status<cr>", "status" },
      },
      h = { ":Telescope frecency<cr>", "history" },
      l = {
        name = "+Live",
        g = { ":Telescope live_grep<cr>", "grep" },
        w = { ":Telescope grep_string<cr>", "current word" },
        e = { ":Telescope grep_string_prompt<cr>", "prompt" },
      },
      r = {
        name = "+Config",
        b = { ":Telescope nvim_files branches<cr>", "branches" },
        B = { ":Telescope nvim_files bcommits<cr>", "bcommits" },
        c = { ":Telescope nvim_files commits<cr>", "commits" },
        f = { ":Telescope nvim_files files<cr>", "nvim files" },
        g = { ":Telescope nvim_files grep_files<cr>", "grep files" },
        I = { ":Telescope nvim_files view_changelog<cr>", "view changelog" },
        s = { ":Telescope nvim_files status<cr>", "status" },
      },
      t = {
        name = "+Tmux",
        s = { ":Telescope tmux sessions<cr>", "sessions" },
        w = { ":Telescope tmux windows<cr>", "windows" },
        e = { ":Telescope tmux pane_contents<cr>", "pane contents" },
      },
      v = {
        name = "+Lsp",
        a = { ":Telescope lsp_code_actions<cr>", "code action" },
        A = { ":Telescope lsp_range_code_actions<cr>", "range code action" },
        r = { ":Telescope lsp_references<cr>", "references" },
        d = { ":Telescope lsp_document_symbols<cr>", "document_symbol" },
        w = { ":Telescope lsp_workspace_symbols<cr>", "workspace_symbol" },
      },
      x = {
        name = "+Extensions",
        b = { ":Telescope bg_selector<cr>", "change background" },
      },
    },
  }
end
