local vim = vim
local mapk = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}

require('telescope').setup({
  defaults = {
    file_sorter = require('telescope.sorters').get_fzy_sorter
  }
})

-- Using lua functions
mapk('n', '<C-k>', ':lua require("telescope.builtin").find_files()<CR>', opts)
mapk('n', '<Leader>ff', ':lua require("telescope.builtin").builtin()<CR>', opts)
mapk('n', '<Leader>fr', ':lua require("telescope.builtin").keymaps()<CR>', opts)
mapk('n', '<Leader>fb', ':lua require("telescope.builtin").buffers()<CR>', opts)
mapk('n', '<Leader>fh', ':lua require("telescope.builtin").help_tags()<CR>', opts)
mapk('n', '<Leader>fl', ':lua require("telescope.builtin").live_grep()<CR>', opts)
mapk('n', '<Leader>fw', ':lua require("telescope.builtin").grep_string { search = vim.fn.expand("<cword>") }<CR>', opts)
mapk('n', '<Leader>fs', ':lua require("telescope.builtin").grep_string({ search = vim.fn.input("Grep For > ")})<CR>', opts)

-- Git Pickers
mapk('n', '<Leader>fgb', ':lua require("telescope.builtin").git_branches()<CR>', opts)
mapk('n', '<Leader>fgc', ':lua require("telescope.builtin").git_commits()<CR>', opts)
mapk('n', '<Leader>fgC', ':lua require("telescope.builtin").git_bcommits()<CR>', opts)
mapk('n', '<Leader>fgf', ':lua require("telescope.builtin").git_files()<CR>', opts)
mapk('n', '<Leader>fgs', ':lua require("telescope.builtin").git_status()<CR>', opts)
