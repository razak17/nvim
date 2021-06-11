local nmap = r17.nmap
local nnoremap = r17.nnoremap
local xnoremap = r17.xnoremap
local vnoremap = r17.vnoremap
local inoremap = r17.inoremap
local tnoremap = r17.tnoremap
local cnoremap = r17.cnoremap
local utils = require 'internal.utils'

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

nnoremap("<leader>E", function() utils.token_inspect() end, {silent = false})

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

-- Terminal {{{
r17.augroup("AddTerminalMappings", {
  {
    events = {"TermOpen"},
    targets = {"term://*"},
    command = function()
      if vim.bo.filetype == "" or vim.bo.filetype == "toggleterm" then
        local opts = {silent = false, buffer = 0}
        tnoremap("<esc>", [[<C-\><C-n>]], opts)
        tnoremap("jk", [[<C-\><C-n>]], opts)
        tnoremap("<C-h>", [[<C-\><C-n><C-W>h]], opts)
        tnoremap("<C-j>", [[<C-\><C-n><C-W>j]], opts)
        tnoremap("<C-k>", [[<C-\><C-n><C-W>k]], opts)
        tnoremap("<C-l>", [[<C-\><C-n><C-W>l]], opts)
        tnoremap("]t", [[<C-\><C-n>:tablast<CR>]])
        tnoremap("[t", [[<C-\><C-n>:tabnext<CR>]])
        tnoremap("<S-Tab>", [[<C-\><C-n>:bprev<CR>]])
        tnoremap("<leader><Tab>", [[<C-\><C-n>:close \| :bnext<cr>]])
      end
    end
  }
})

-- Add Empty space above and below
nnoremap("[<space>", [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]])
nnoremap("]<space>", [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]])

-- Paste in visual mode multiple times
xnoremap("p", "pgvy")

-- search visual selection
vnoremap("//", [[y/<C-R>"<CR>]])

-- Windows
-- Change two horizontally split windows to vertical splits
nnoremap("<localleader>wh", "<C-W>t <C-W>K")
-- Change two vertically split windows to horizontal splits
nnoremap("<localleader>wv", "<C-W>t <C-W>H")
-- opens a horizontal split
nnoremap("<C-w>f", "<C-w>vgf")
-- find visually selected text
vnoremap("*", [[y/<C-R>"<CR>]])
-- make . work with visually selected lines
vnoremap(".", ":norm.<CR>")

-- Quick find/replace
local noisy = {silent = false}
nnoremap("<leader>[", [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy)
nnoremap("<leader>]", [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy)
vnoremap("<leader>[", [["zy:%s/<C-r><C-o>"/]], noisy)

-- open a new file in the same directory
nnoremap("<leader>nf", [[:e <C-R>=expand("%:p:h") . "/" <CR>]], {silent = false})
-- create a new file in the same directory
nnoremap("<leader>ns", [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]], {silent = false})

-- Arrows
nnoremap("<down>", "<nop>")
nnoremap("<up>", "<nop>")
nnoremap("<left>", "<nop>")
nnoremap("<right>", "<nop>")
inoremap("<up>", "<nop>")
inoremap("<down>", "<nop>")
inoremap("<left>", "<nop>")
inoremap("<right>", "<nop>")

-- Repeat last substitute with flags
nnoremap("&", "<cmd>&&<CR>")
xnoremap("&", "<cmd>&&<CR>")

----------------------------------------------------------------------------------
-- Commandline mappings
----------------------------------------------------------------------------------
-- https://github.com/tpope/vim-rsi/blob/master/plugin/rsi.vim
-- c-a / c-e everywhere - RSI.vim provides these
-- cnoremap("<C-n>", "<Down>")
cnoremap("<C-p>", "<Up>")

-- Zero should go to the first non-blank character not to the first column (which could be blank)
nnoremap("0", "^")

-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap("$", "g_")

-- This line opens the vimrc in a vertical split
nnoremap("<leader>ev", [[:vsplit $MYVIMRC<cr>]])

-- Quotes
nnoremap([[<leader>"]], [[ciw"<c-r>""<esc>]])
nnoremap("<leader>`", [[ciw`<c-r>"`<esc>]])
nnoremap("<leader>'", [[ciw'<c-r>"'<esc>]])
nnoremap("<leader>)", [[ciw(<c-r>")<esc>]])
nnoremap("<leader>}", [[ciw{<c-r>"}<esc>]])

-- Map Q to replay q register
nnoremap("Q", "@q")

-- if the file under the cursor doesn't exist create it
-- see :h gf a simpler solution of :edit <cfile> is recommended but doesn't work.
-- If you select require('buffers/file') in lua for example
-- this makes the cfile -> buffers/file rather than my_dir/buffer/file.lua
-- Credit: 1,2
nnoremap("gf", function() utils.open_file_or_create_new() end)

-----------------------------------------------------------------------------//
-- Command mode related
-----------------------------------------------------------------------------//
-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
cnoremap("<Tab>", [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>/<C-r>/" : "<C-z>"]],
         {expr = true})
cnoremap("<S-Tab>", [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>?<C-r>/" : "<S-Tab>"]],
         {expr = true})
-- Smart mappings on the command line
cnoremap("w!!", [[w !sudo tee % >/dev/null]])
-- insert path of current file into a command
cnoremap("%%", "<C-r>=fnameescape(expand('%'))<cr>")
cnoremap("::", "<C-r>=fnameescape(expand('%:p:h'))<cr>/")

-- GX - replicate netrw functionality
nnoremap("gX", function() utils.open_link() end)

-- toggle_list
nnoremap("<leader>ls", function() utils.toggle_list("c") end)
nnoremap("<leader>li", function() utils.toggle_list("l") end)

-----------------------------------------------------------------------------//
-- Commands
-----------------------------------------------------------------------------//

r17.command {"Todo", [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]]}

-- Other remaps
nnoremap('<Leader>,', ':e ~/.config/nvim/lua/core/init.lua<CR>')
nnoremap('<Leader>.', ':e $MYVIMRC<CR>')
nnoremap('<Leader>Ic', ':checkhealth<CR>')
nnoremap('<Leader>vwm', function() require"modules.aesth.config".ColorMyPencils() end)
nnoremap('<leader>ar', function() utils.rename() end)
nnoremap('<leader>aR', function() utils.EmptyRegisters() end)
nnoremap('<Leader>;', function() utils.OpenTerminal() end)
nnoremap('<leader>ao', function() utils.TurnOnGuides() end)
nnoremap('<leader>ae', function() utils.TurnOffGuides() end)
