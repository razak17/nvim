local actions = require('telescope.actions')

vim.cmd [[packadd plenary.nvim]]
vim.cmd [[packadd popup.nvim]]
vim.cmd [[packadd telescope-fzy-native.nvim]]
vim.cmd [[packadd telescope-media-files.nvim]]
vim.cmd [[packadd telescope-packer.nvim]]
vim.cmd [[packadd telescope-dap.nvim]]
vim.cmd [[packadd telescope-project.nvim]]

require('telescope').setup({
  defaults = {
    prompt_prefix = "> ",
    selection_caret = " ",
    sorting_strategy = "ascending",
    file_ignore_patterns = {
      "target/*",
      "node_modules/*",
      "dist/*",
      ".git/*",
      ".venv/*"
    },
    borderchars = {'─', '│', '─', '│', '┌', '┐', '┘', '└'},
    file_sorter = require'telescope.sorters'.get_fzy_sorter,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    mappings = {i = {["<C-e>"] = actions.send_to_qflist}},
    file_browser = {hidden = true},
    extensions = {
      fzy_native = {
        override_generic_sorter = false,
        override_file_sorter = true
      },
      media_files = {
        filetypes = {"png", "webp", "jpg", "jpeg"},
        find_cmd = "rg"
      }
    }
  }
})

require'telescope'.load_extension('media_files')
require'telescope'.load_extension('fzy_native')
require'telescope'.load_extension('project')
require'telescope'.load_extension('nvim_files')
require'telescope'.load_extension('dotfiles')
require'telescope'.load_extension('grep_string_prompt')
require'telescope'.load_extension('bg_selector')
