return function()
  local telescope_ok, telescope = pcall(require, "telescope")
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
          fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
          },
          media_files = {
            filetypes = { "png", "webp", "jpg", "jpeg" },
            find_cmd = "rg",
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

  if rvim.plugin_loaded "telescope-fzy-native.nvim" then
    vim.cmd [[packadd telescope-fzy-native.nvim]]
    require("telescope").load_extension "fzy_native"
  end

  if rvim.plugin_loaded "telescope-project.nvim" then
    vim.cmd [[packadd telescope-project.nvim]]
    require("telescope").load_extension "project"
  end

  if rvim.plugin_loaded "telescope-media-files.nvim" then
    vim.cmd [[packadd telescope-media-files.nvim]]
    require("telescope").load_extension "media_files"
  end

  if rvim.plugin_loaded "project.nvim" then
    vim.cmd [[packadd project.nvim]]
    require("telescope").load_extension "projects"
  end

  local extensions = {
    "grep_string_prompt",
    "bg_selector",
    -- TODO: Fix not a git directory error for the two below.
    "nvim_files",
    "dotfiles",
  }

  for _, ext in ipairs(extensions) do
    require("telescope").load_extension(ext)
  end
end
