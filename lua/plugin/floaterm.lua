vim.g.floaterm_borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'}
-- vim.g.floaterm_borderchars = {'═', '║', '═', '║', '╔', '╗', '╝', '╚'}

-- Set floaterm window's background to black
vim.cmd("hi FloatermBorder guifg=#7ec0ee")
vim.cmd("autocmd FileType floaterm setlocal winblend=0")

-- vim.g.floaterm_wintype='normal'

vim.g.floaterm_keymap_new    = '<F7>'
vim.g.floaterm_keymap_prev   = '<F8>'
vim.g.floaterm_keymap_next   = '<F9>'
-- vim.g.floaterm_keymap_kill   = '<F10>'
vim.g.floaterm_keymap_toggle = '<F12>'

-- Floaterm
vim.g.floaterm_gitcommit='floaterm'
vim.g.floaterm_autoinsert=1
vim.g.floaterm_width=0.8
vim.g.floaterm_height=0.8
vim.g.floaterm_wintitle=''
vim.g.floaterm_autoclose=1

