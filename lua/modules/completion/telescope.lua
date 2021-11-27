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
        { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
        preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      },
    })
  end

  ---@param opts table
  ---@return table
  local function dropdown(opts)
    return themes.get_dropdown(get_border(opts))
  end

  rvim.telescope = {
    setup = {
      defaults = {
        prompt_prefix = " ❯ ",
        selection_caret = " ",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        set_env = { ["TERM"] = vim.env.TERM },
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        file_browser = { hidden = true },
        layout_config = {
          height = 0.9,
          width = 0.9,
          preview_cutoff = 120,
          horizontal = { mirror = false },
          vertical = { mirror = false },
        },
        winblend = 3,
        history = {
          path = get_runtime_dir() .. "/telescope_history.sqlite3",
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
            ["<C-n>"] = actions.move_selection_next,
            ["<C-b>"] = actions.move_selection_previous,
            ["<esc>"] = actions.close,
            ["<C-'>"] = actions.cycle_history_next,
            ["<C-k>"] = actions.cycle_history_prev,
            ["<C-e>"] = actions.smart_send_to_qflist + actions.open_qflist,
            ["<c-s>"] = actions.select_horizontal,
            ["<CR>"] = actions.select_default + actions.center,
          },
          n = {
            ["<C-n>"] = actions.move_selection_next,
            ["<C-b>"] = actions.move_selection_previous,
            ["<C-e>"] = actions.smart_send_to_qflist + actions.open_qflist,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
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
end
