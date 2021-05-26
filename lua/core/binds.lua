local mp = require('keymap.map')
local nmap, nnoremap, inoremap, vnoremap, xnoremap, tnoremap = mp.nmap,
                                                               mp.nnoremap,
                                                               mp.inoremap,
                                                               mp.vnoremap,
                                                               mp.xnoremap,
                                                               mp.tnoremap

-- Basic Key Mappings
-- nnoremap('z', ':undo<CR>')

-- Yank from cursor position to end-of-line
nnoremap('Y', 'y$')

-- Easier line-wise movement
-- nnoremap("gh", "g^")
-- nnoremap("gl", "g$")

-- Move selected line / block of text in visual mode
xnoremap('K', ":m '<-2<CR>gv=gv")
xnoremap('N', ":m '>+1<CR>gv=gv")

-- Open url
nnoremap('gx', ":sil !xdg-open <c-r><c-a><cr>")

-- Better Navigation
nnoremap('<C-h>', '<C-w>h')
nnoremap('<C-n>', '<C-w>j')
nnoremap('<C-k>', '<C-w>k')
nnoremap('<C-l>', '<C-w>l')

-- Start new line from any cursor position
inoremap("<S-Return>", "<C-o>o")

-- Use alt + hjkl to resize windows
nnoremap('<M-n>', ':resize -2<CR>')
nnoremap('<M-k>', ':resize +2<CR>')
nnoremap('<M-h>', ':vertical resize -2<CR>')
nnoremap('<M-l>', ':vertical resize +2<CR>')

-- Window Resize
nnoremap('<Leader>ca', ':vertical resize 40<CR>')
nnoremap('<Leader>aF', ':vertical resize 90<CR>')

-- Search Files
nnoremap('<Leader>chw', ':h <C-R>=expand("<cword>")<CR><CR>')
nnoremap('<Leader>bs', '/<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>')

-- Terminal window Navigation
tnoremap('<C-h>', '<C-\\><C-N><C-w>h')
tnoremap('<C-j>', '<C-\\><C-N><C-w>j')
tnoremap('<C-k>', '<C-\\><C-N><C-w>k')
tnoremap('<C-l>', '<C-\\><C-N><C-w>l')
inoremap('<C-h>', '<C-\\><C-N><C-w>h')
inoremap('<C-j>', '<C-\\><C-N><C-w>j')
inoremap('<C-k>', '<C-\\><C-N><C-w>k')
inoremap('<C-l>', '<C-\\><C-N><C-w>l')
tnoremap('<Esc>', '<C-\\><C-N>')

-- TAB in general mode will move to text buffer, SHIFT-TAB will go back
nnoremap('<TAB>', ':bnext<CR>')
nnoremap('<S-TAB>', ':bprevious<CR>')

-- Tab navigation
nnoremap('<Leader>sb', ':tabprevious<CR>')
nnoremap('<Leader>sK', ':tablast<CR>')
nnoremap('<Leader>sk', ':tabfirst<CR>')
nnoremap('<Leader>sn', ':tabnext<CR>')
nnoremap('<Leader>sN', ':tabnew<CR>')
nnoremap('<Leader>sd', ':tabclose<CR>')
nnoremap('<Leader>sH', ':-tabmove<CR>')
nnoremap('<Leader>sL', ':+tabmove<CR>')

-- Alternate way to save
nnoremap('<C-s>', ':w<CR>')

-- Alternate way to quit
nnoremap("<Leader>ax", ":wq!<CR>")
nnoremap("<Leader>az", ":q!<CR>")
nmap('W', 'q')
nnoremap('<Leader>x', ':q<CR>')
nnoremap('<C-z>', ':undo<CR>')

-- Use control-c instead of escape
nnoremap('<C-c>', '<Esc>')

-- Better tabbing
vnoremap('<', '<gv')
vnoremap('>', '>gv')

-- Greatest remap ever
vnoremap('<Leader>p', '"_dP')

-- Next greatest remap ever : asbjornHaland
nnoremap('<Leader>y', '"+y')
vnoremap('<Leader>y', '"+y')
nnoremap('<Leader>aY', 'gg"+yG')
nnoremap('<Leader>aV', 'gg"+VG')
nnoremap('<Leader>aD', 'gg"+VGd')

-- actions
nnoremap("<Leader>=", "<C-W>=")
nnoremap("<Leader>ah", "<C-W>s")
nnoremap("<Leader>av", "<C-W>v")
nnoremap("<Leader>an", ":let @/ = ''<CR>")
nnoremap("<Leader>aN", ":set nonumber!<CR>")
nnoremap("<Leader>aR", ":set norelativenumber!<CR>")
nnoremap("<Leader>ad", ":bdelete!<CR>")

-- Session
nnoremap("<Leader>Sl", ":SessionLoad<CR>")
nnoremap("<Leader>Ss", ":SessionSave<CR>")

-- Folds
nnoremap("<S-Return>", "zMzvzt")
nnoremap("<Leader>afr", "zA") -- Recursively toggle
nnoremap("<Leader>afl", "za") -- Toggle fold under the cursor
nnoremap("<Leader>afo", "zR") -- Open all folds
nnoremap("<Leader>afx", "zM") -- Close all folds
nnoremap("<Leader>aO", ":set fo-=cro<CR>") -- Close all folds

-- qflist
nnoremap("<Leader>vo", ":copen<CR>")

-- Other remaps
nnoremap('<Leader>,', ':e ~/.config/nvim/lua/core/init.lua<CR>')
nnoremap('<Leader>.', ':e $MYVIMRC<CR>')
nnoremap('<leader>cR', ':call autocmds#EmptyRegisters()<CR>')
nnoremap('<Leader>Ic', ':checkhealth<CR>')
nnoremap('<Leader>vwm',
         ':lua require "modules.aesth.config".ColorMyPencils()<CR>')
nnoremap('<Leader>;', ':lua require "internal.utils".OpenTerminal()<CR>')
nnoremap('<leader>ao', ':lua require "internal.utils".TurnOnGuides()<CR>')
nnoremap('<leader>ae', ':lua require "internal.utils".TurnOffGuides()<CR>')

