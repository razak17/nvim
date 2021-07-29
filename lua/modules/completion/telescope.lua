local actions = require "telescope.actions"

require("telescope").setup {
  defaults = {
    prompt_prefix = rvim.telescope.prompt_prefix,
    selection_caret = " ",
    sorting_strategy = "ascending",
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
    layout_strategy = "horizontal",
    layout_config = rvim.telescope.layout_config,
    borderchars = rvim.telescope.borderchars,
    file_sorter = require("telescope.sorters").get_fzy_sorter,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    mappings = {
      i = {
        ["<c-c>"] = function()
          vim.cmd "stopinsert!"
        end,
        ["<esc>"] = actions.close,
        ["<c-s>"] = actions.select_horizontal,
        ["<C-e>"] = actions.send_to_qflist,
      },
    },
    file_browser = { hidden = true },
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
  },
}

if rvim.plugin.telescope_fzy.active then
  vim.cmd [[packadd telescope-fzy-native.nvim]]
  require("telescope").load_extension "fzy_native"
end

if rvim.plugin.telescope_project.active then
  vim.cmd [[packadd telescope-project.nvim]]
  require("telescope").load_extension "project"
end

if rvim.plugin.telescope_media_files.active then
  vim.cmd [[packadd telescope-media-files.nvim]]
  require("telescope").load_extension "media_files"
end

local extensions = {
  "grep_string_prompt",
  "bg_selector",
  "nvim_files",
  "dotfiles",
}

local function load_extensions(exps)
  for _, ext in ipairs(exps) do
    require("telescope").load_extension(ext)
  end
end
load_extensions(extensions)
