return function()
  local telescope_ok, telescope = rvim.safe_require "telescope"
  if not telescope_ok then
    return
  end

  local previewers = require "telescope.previewers"
  local sorters = require "telescope.sorters"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local layout_actions = require "telescope.actions.layout"
  local themes = require "telescope.themes"

  -- https://github.com/nvim-telescope/telescope.nvim/issues/1048
  -- Ref: https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/telescope/init.lua
  local telescope_custom_actions = {}

  function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local num_selections = #picker:get_multi_selection()
    if not num_selections or num_selections <= 1 then
      actions.add_selection(prompt_bufnr)
    end
    actions.send_selected_to_qflist(prompt_bufnr)
    vim.cmd("cfdo " .. open_cmd)
  end

  function telescope_custom_actions.multi_selection_open(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "edit")
  end

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
        color_devicons = true,
        dynamic_preview_title = true,
        layout_config = {
          height = 0.9,
          width = 0.9,
          preview_cutoff = 120,
          horizontal = {
            width_padding = 0.04,
            height_padding = 0.1,
            preview_width = 0.6,
          },
          vertical = {
            width_padding = 0.05,
            height_padding = 0.1,
            preview_height = 0.5,
          },
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
            ["<c-e>"] = layout_actions.toggle_preview,
            ["<c-l>"] = layout_actions.cycle_layout_next,
            ["<C-A>"] = telescope_custom_actions.multi_selection_open,
          },
          n = {
            ["<C-n>"] = actions.move_selection_next,
            ["<C-p>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            ["<C-A>"] = telescope_custom_actions.multi_selection_open,
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
          file_browser = {
            theme = "ivy",
            mappings = {
              ["i"] = {
                i = {
                  ["<C-h>"] = require("telescope").extensions.file_browser.actions.goto_home_dir,
                },
              },
              ["n"] = {
                n = {
                  ["<C-h>"] = require("telescope").extensions.file_browser.actions.goto_home_dir,
                  f = false,
                },
              },
            },
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
    project = "projects",
    telescope_dap = "dap",
    telescope_fzf = "fzf",
    telescope_ui_select = "ui-select",
    telescope_tmux = "tmux",
    telescope_frecency = "frecency",
    telescope_file_browser = "file_browser",
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
  }

  for _, ext in ipairs(extensions) do
    require("telescope").load_extension(ext)
  end

  --- NOTE: this must be required after setting up telescope
  --- otherwise the result will be cached without the updates
  --- from the setup call
  local builtins = require "telescope.builtin"

  local function notes()
    builtins.find_files {
      prompt_title = "Notes",
      cwd = vim.fn.expand "~/notes/src/",
    }
  end

  local function installed_plugins()
    require("telescope.builtin").find_files {
      prompt_title = "Plugins",
      cwd = vim.fn.stdpath "data" .. "/site/pack/packer",
    }
  end

  local function tmux_sessions()
    telescope.extensions.tmux.sessions {}
  end

  local function tmux_windows()
    telescope.extensions.tmux.windows {
      entry_format = "#S: #T",
    }
  end

  local function project_files(opts)
    if not pcall(builtins.git_files, opts) then
      builtins.find_files(opts)
    else
      builtins.find_files()
    end
  end

  -- extensions
  local function file_browser()
    telescope.extensions.file_browser.file_browser {}
  end

  local function grep_string_prompt()
    telescope.extensions.grep_string_prompt.grep_string_prompt {}
  end

  local function frecency()
    telescope.extensions.frecency.frecency(dropdown {
      -- NOTE: remove default text as it's slow
      -- default_text = ':CWD:',
      winblend = 10,
      border = true,
      previewer = false,
      shorten_path = false,
    })
  end

  local function projects()
    telescope.extensions.projects.projects {}
  end

  local function change_bg()
    telescope.extensions.bg_selector.bg_selector {}
  end

  require("which-key").register {
    ["<c-p>"] = { project_files, "telescope: find files" },
    ["<leader>la"] = { builtins.lsp_code_actions, "code action" },
    ["<leader>lA"] = { builtins.lsp_range_code_actions, "range code action" },
    ["<leader>lR"] = { builtins.lsp_references, "references" },
    ["<leader>f"] = {
      name = "+Telescope",
      a = { builtins.builtin, "builtins" },
      b = { builtins.current_buffer_fuzzy_find, "find in current buffer" },
      g = { builtins.live_grep, "find word" },
      R = { builtins.reloader, "module reloader" },
      r = { builtins.oldfiles, "history" },
      w = { builtins.grep_string, "find current word" },
      P = { installed_plugins, "plugins" },
      B = { file_browser, "find browser" },
      e = { grep_string_prompt, "find in prompt" },
      h = { frecency, "history" },
      n = { notes, "notes" },
      p = { projects, "recent projects" },
      W = { change_bg, "change background" },
      c = {
        name = "+Builtin",
        a = { builtins.autocommands, "autocmds" },
        b = { builtins.buffers, "buffers" },
        c = { builtins.commands, "commands" },
        h = { builtins.help_tags, "help" },
        H = { builtins.command_history, "history" },
        l = { builtins.loclist, "loclist" },
        q = { builtins.quickfix, "quickfix" },
        r = { builtins.registers, "registers" },
        v = { builtins.vim_options, "vim options" },
      },
      L = {
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
        name = "+tmux",
        s = { tmux_sessions, "sessions" },
        w = { tmux_windows, "windows" },
      },
    },
  }
end
