local mappings = require('utils.map')
local actions = require 'telescope.actions'
local nnoremap = mappings.nnoremap

vim.cmd("hi TelescopeBorder guifg=#7ec0ee")

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-x>"] = false,
        ["<C-e>"] = actions.select_tab,
        ["<CR>"] = actions.select_default,
        ["<C-b>"] = actions.move_selection_previous,
        ["<C-v>"] = actions.select_vertical,
        ["<C-i>"] = actions.select_horizontal,
      },
    },
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    extensions = {
      fzy_native = {
        override_generic_sorter = false,
        override_file_sorter = true,
      }
    },
    prompt_prefix = ">",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    file_ignore_patterns = {"target/*"},
    shorten_path = true,
    winblend = 0,
    width = 0.75,
    preview_cutoff = 120,
    results_height = 1,
    results_width = 0.8,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰'},
    -- borderchars = {'═', '║', '═', '║', '╔', '╗', '╝', '╚'},
    color_devicons = true,
    use_less = true,
    set_env = { ['COLORTERM'] = 'truecolor' },
    file_sorter =  require'telescope.sorters'.get_fzy_sorter,
    generic_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
  }
})

require('telescope').load_extension('fzy_native')

-- Finder
nnoremap('<Leader>ff', ':lua require("telescope.builtin").find_files()<CR>')
nnoremap('<Leader>fcs', ':lua require("utils.funcs").search_dotfiles()<CR>')

-- Commands
nnoremap('<Leader>fce', ':lua require"telescope.builtin".planets{}<CR>')
nnoremap('<Leader>fcA', ':lua require("telescope.builtin").autocommands()<CR>')
nnoremap('<Leader>fcb', ':lua require("telescope.builtin").buffers()<CR>')
nnoremap('<Leader>fcc', ':lua require("telescope.builtin").commands()<CR>')
nnoremap('<Leader>fcf', ':lua require("telescope.builtin").builtin()<CR>')
nnoremap('<Leader>fch', ':lua require("telescope.builtin").help_tags()<CR>')
nnoremap('<Leader>fcH', ':lua require("telescope.builtin").command_history()<CR>')
nnoremap('<Leader>fck', ':lua require("telescope.builtin").keymaps()<CR>')
nnoremap('<Leader>fcl', ':lua require("telescope.builtin").loclist()<CR>')
nnoremap('<Leader>fco', ':lua require("telescope.builtin").oldfiles()<CR>')
nnoremap('<Leader>fcr', ':lua require("telescope.builtin").registers()<CR>')
nnoremap('<Leader>fcT', ':lua require("telescope.builtin").treesitter()<CR>')
nnoremap('<Leader>fcv', ':lua require("telescope.builtin").vim_options()<CR>')
nnoremap('<Leader>fcz', ':lua require("telescope.builtin").current_buffer_fuzzy_find()<CR>')

-- Lsp
nnoremap('<Leader>fva', ':lua require("telescope.builtin").lsp_code_action()<CR>')
nnoremap('<Leader>fvr', ':lua require("telescope.builtin").lsp_references()<CR>')
nnoremap('<Leader>fvsd', ':lua require("telescope.builtin").lsp_document_symbols()<CR>')
nnoremap('<Leader>fvsw', ':lua require("telescope.builtin").lsp_workspace_symbols()<CR>')

-- Live
nnoremap('<Leader>flg', ':lua require("telescope.builtin").live_grep()<CR>')
nnoremap('<Leader>flw', ':lua require("telescope.builtin").grep_string { search = vim.fn.expand("<cword>") }<CR>')
nnoremap('<Leader>fle', ':lua require("telescope.builtin").grep_string({ search = vim.fn.input("Grep For > ")})<CR>')

-- Git
nnoremap('<Leader>fgb', ':lua require("telescope.builtin").git_branches()<CR>')
nnoremap('<Leader>fgc', ':lua require("telescope.builtin").git_commits()<CR>')
nnoremap('<Leader>fgC', ':lua require("telescope.builtin").git_bcommits()<CR>')
nnoremap('<Leader>fgf', ':lua require("telescope.builtin").git_files()<CR>')
nnoremap('<Leader>fgs', ':lua require("telescope.builtin").git_status()<CR>')

-- Extensions
nnoremap('<leader>fee', ':lua require("telescope").extensions.packer.plugins()<CR>')

