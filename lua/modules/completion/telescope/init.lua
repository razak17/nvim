local actions = require('telescope.actions')

require('telescope').setup({
  defaults = {
    prompt_prefix = "> ",
    selection_caret = " ",
    sorting_strategy = "ascending",
    file_ignore_patterns = {"target/*", "node_modules/*", "dist/*", ".git/*"},
    width = 0.75,
    border = {},
    borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'},
    set_env = {['COLORTERM'] = 'truecolor'},
    vimgrep_arguments = {
      'rg', '--no-heading', '--with-filename', '--line-number', '--column',
      '--smart-case'
    },
    file_sorter = require'telescope.sorters'.get_fzy_sorter,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    mappings = {
      i = {
        ["<C-x>"] = false,
        ["<CR>"] = actions.select_default,
        ["<C-b>"] = actions.move_selection_previous,
        ["<C-v>"] = actions.select_vertical,
        ["<C-i>"] = actions.select_horizontal,
        ["<C-e>"] = actions.send_to_qflist
      }
    },
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
require'telescope'.load_extension('packer')
require'telescope'.load_extension('fzy_native')
require'telescope'.load_extension('dotfiles')
