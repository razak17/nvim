return function()
  local telescope_ok, telescope = rvim.safe_require "telescope"
  if not telescope_ok then
    return
  end

  local previewers = require "telescope.previewers"
  local sorters = require "telescope.sorters"
  local actions = require "telescope.actions"

  rvim.telescope = {
    setup = {
      defaults = {
        prompt_prefix = " ❯ ",
        selection_caret = " ",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        file_browser = { hidden = true },
        layout_config = {
          height = 0.9,
          width = 0.9,
          preview_cutoff = 120,
          horizontal = { mirror = false },
          vertical = { mirror = false },
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
        mappings = {
          i = {
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
        pickers = {
          find_files = {
            find_command = { "fd", "--type=file", "--hidden", "--smart-case" },
          },
          live_grep = {
            --@usage don't include the filename in the search results
            only_sort_text = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          },
        },
        file_sorter = sorters.get_fzy_sorter,
        file_previewer = previewers.vim_buffer_cat.new,
        grep_previewer = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,
      },
    },
  }

  telescope.setup(rvim.telescope.setup)

  if rvim.plugin.telescope_fzf.active then
    require("telescope").load_extension "fzf"
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
