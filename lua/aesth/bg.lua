local vim = vim
local g = vim.g
local cmd = vim.cmd

g.nvcode_termcolors=256
vim.cmd [[ colo onedark ]]
-- colorscheme nord
-- colorscheme nvcode
-- colorscheme TSnazzy
-- colorscheme aurora
-- colorscheme gruvbox
-- colorscheme palenight

cmd('autocmd ColorScheme * highlight clear SignColumn')
cmd('autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE')

cmd('hi LineNr ctermbg=NONE guibg=NONE ')
cmd('hi Comment cterm=italic')

g.onedark_hide_endofbuffer=1
g.onedark_terminal_italics=1
g.onedark_termcolors=256
