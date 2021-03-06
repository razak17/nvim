local actions = require('telescope.actions')

require('telescope').setup({
  defaults = {
    prompt_prefix = core.telescope.prompt_prefix,
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
    layout_config = core.telescope.layout_config,
    borderchars = core.telescope.borderchars,
    file_sorter = require'telescope.sorters'.get_fzy_sorter,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    mappings = {i = {["<C-e>"] = actions.send_to_qflist}},
    file_browser = {hidden = true},
    extensions = {
      fzy_native = {
        override_generic_sorter = false,
        override_file_sorter = true,
      },
      media_files = {
        filetypes = {"png", "webp", "jpg", "jpeg"},
        find_cmd = "rg",
      },
    },
  },
})

if core.plugin.telescope_fzy.active then
  vim.cmd [[packadd telescope-fzy-native.nvim]]
  require'telescope'.load_extension('fzy_native')
end

if core.plugin.telescope_project.active then
  vim.cmd [[packadd telescope-project.nvim]]
  require'telescope'.load_extension('project')
end

if core.plugin.telescope_media_files.active then
  vim.cmd [[packadd telescope-media-files.nvim]]
  require'telescope'.load_extension('media_files')
end

require'telescope'.load_extension('grep_string_prompt')
require'telescope'.load_extension('bg_selector')
require'telescope'.load_extension('nvim_files')
require'telescope'.load_extension('dotfiles')

