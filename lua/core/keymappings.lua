local nnoremap, cnoremap, tnoremap, vnoremap, xnoremap, inoremap =
  rvim.keys.nnoremap, rvim.keys.cnoremap, rvim.keys.tnoremap, rvim.keys.vnoremap, rvim.keys.xnoremap, rvim.keys.inoremap

-- Use alt + hjkl to resize windows
nnoremap["<M-n>"] = ":resize -2<CR>"
nnoremap["<M-k>"] = ":resize +2<CR>"
nnoremap["<M-h>"] = ":vertical resize +2<CR>"
nnoremap["<M-l>"] = ":vertical resize -2<CR>"

-- Yank from cursor position to end-of-line
nnoremap["Y"] = "y$"

-- Easy way to close popups windows
nnoremap["W"] = { "q", { noremap = false, silent = true } }

-- Open url
nnoremap["gx"] = ":sil !xdg-open <c-r><c-a><cr>"

-- Repeat last substitute with flags
nnoremap["&"] = "<cmd>&&<CR>"

-- Zero should go to the first non-blank character not to the first column (which could be blank)
nnoremap["0"] = "^"

-- Map Q to replay q register
nnoremap["Q"] = "@q"

-- Add Empty space above and below
nnoremap["[<space>"] = [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]]
nnoremap["]<space>"] = [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]]

-- Window Resize
nnoremap["<Leader>ca"] = ":vertical resize 40<CR>"
nnoremap["<Leader>aF"] = ":vertical resize 90<CR>"

-- Search Files
nnoremap["<Leader>chw"] = ':h <C-R>=expand("<cword>")<CR><CR>'
nnoremap["<Leader>bs"] = '/<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>'

-- Tab navigation
nnoremap["<Leader>sb"] = ":tabprevious<CR>"
nnoremap["<Leader>sK"] = ":tablast<CR>"
nnoremap["<Leader>sk"] = ":tabfirst<CR>"
nnoremap["<Leader>sn"] = ":tabnext<CR>"
nnoremap["<Leader>sN"] = ":tabnew<CR>"
nnoremap["<Leader>sd"] = ":tabclose<CR>"
nnoremap["<Leader>sH"] = ":-tabmove<CR>"
nnoremap["<Leader>sL"] = ":+tabmove<CR>"

-- Alternate way to quit
nnoremap["<Leader>ax"] = ":wq!<CR>"
nnoremap["<Leader>az"] = ":q!<CR>"
nnoremap["<Leader>x"] = ":q<CR>"

-- Greatest remap ever
vnoremap["<Leader>p"] = '"_dP'

-- Greatest remap ever
vnoremap["<Leader>rev"] = [[:s/\%V.\+\%V./\=utils#rev_str(submatch(0))<CR>gv]]

-- Next greatest remap ever : asbjornHaland
nnoremap["<Leader>y"] = '"+y'
vnoremap["<Leader>y"] = '"+y'

-- Whole file delete yank, paste
nnoremap["<Leader>aY"] = 'gg"+yG'
nnoremap["<Leader>aV"] = 'gg"+VG'
nnoremap["<Leader>aD"] = 'gg"+VGd'

-- actions
nnoremap["<Leader>="] = "<C-W>="
-- opens a horizontal split
nnoremap["<Leader>ah"] = "<C-W>s"
-- opens a vertical split
nnoremap["<Leader>av"] = "<C-W>v"
-- Change two horizontally split windows to vertical splits
nnoremap["<localleader>wv"] = "<C-W>t <C-W>H<C-W>="
-- Change two vertically split windows to horizontal splits
nnoremap["<localleader>wh"] = "<C-W>t <C-W>K<C-W>="
-- delete buffer
nnoremap["<Leader>ad"] = ":bdelete!<CR>"

-- opens the last buffer
nnoremap["<leader>al"] = "<C-^>"

-- Folds
nnoremap["<S-Return>"] = "zMzvzt"
nnoremap["<Leader>afr"] = "zA" -- Recursively toggle
nnoremap["<Leader>afl"] = "za" -- Toggle fold under the cursor
nnoremap["<Leader>afo"] = "zR" -- Open all folds
nnoremap["<Leader>afx"] = "zM" -- Close all folds
nnoremap["<Leader>aO"] = ":<C-f>:resize 10<CR>" -- Close all folds

-- Conditionally modify character at end of line
nnoremap["<localleader>,"] = "<cmd>call utils#modify_line_end_delimiter(',')<cr>"
nnoremap["<localleader>;"] = "<cmd>call utils#modify_line_end_delimiter(';')<cr>"
nnoremap["<localleader>."] = "<cmd>call utils#modify_line_end_delimiter('.')<cr>"

-- qflist
nnoremap["<Leader>vo"] = ":copen<CR>"

-- Quick find/replace
local noisy = { silent = false }
nnoremap["<leader>["] = { [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy }
nnoremap["<leader>]"] = { [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy }
vnoremap["<leader>["] = { [["zy:%s/<C-r><C-o>"/]], noisy }

-- Smart mappings on the command line
cnoremap["w!!"] = [[w !sudo tee % >/dev/null]]

-- insert path of current file into a command
cnoremap["%%"] = "<C-r>=fnameescape(expand('%'))<cr>"
cnoremap["::"] = "<C-r>=fnameescape(expand('%:p:h'))<cr>/"

-- open a new file in the same directory
nnoremap["<leader>nf"] = { [[:e <C-R>=expand("%:p:h") . "/" <CR>]], noisy }
-- create a new file in the same directory
nnoremap["<leader>ns"] = { [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]], noisy }

-- Wrap
nnoremap['<leader>"'] = [[ciw"<c-r>""<esc>]]
nnoremap["<leader>`"] = [[ciw`<c-r>"`<esc>]]
nnoremap["<leader>'"] = [[ciw'<c-r>"'<esc>]]
nnoremap["<leader>)"] = [[ciw(<c-r>")<esc>]]
nnoremap["<leader>}"] = [[ciw{<c-r>"}<esc>]]

-- Other remaps
nnoremap["<Leader>aL"] = ":e ~/.config/rvim/external/utils/.vimrc.local<CR>"

-- Neovim Health check
nnoremap["<Leader>IC"] = ":checkhealth<CR>"
nnoremap["<Leader>Im"] = ":messages<CR>"

-- Buffers
nnoremap["<Leader><Leader>"] = ":call v:lua.DelThisBuffer()<CR>"
nnoremap["<Leader>bdh"] = ":call v:lua.DelToLeft()<CR>"
nnoremap["<Leader>bda"] = ":call v:lua.DelAllBuffers()<CR>"
nnoremap["<Leader>bdx"] = ":call v:lua.DelAllExceptCurrent()<CR>"

-- Terminal mode
tnoremap["<leader><Tab>"] = [[<C-\><C-n>:close \| :bnext<cr>]]

-- QuickRun
nnoremap["<C-b>"] = ":QuickRun<CR>"

-----------------------------------------------------------------------------//
-- Functions
-----------------------------------------------------------------------------//
local utils = require "utils"

-- undo command in insert mode
inoremap["<c-z>"] = function()
  vim.cmd [[:undo]]
end

-- Alternate way to save
nnoremap["<C-s>"] = function()
  utils.save_and_notify()
end

-- if the file under the cursor doesn't exist create it
-- see :h gf a simpler solution of :edit <cfile> is recommended but doesn't work.
-- If you select require('buffers/file') in lua for example
-- this makes the cfile -> buffers/file rather than my_dir/buffer/file.lua
-- Credit: 1,2
nnoremap["gf"] = function()
  utils.open_file_or_create_new()
end

-- GX - replicate netrw functionality
nnoremap["gX"] = function()
  utils.open_link()
end

-- toggle_list
nnoremap["<leader>ls"] = function()
  utils.toggle_list "c"
end

nnoremap["<leader>li"] = function()
  utils.toggle_list "l"
end

nnoremap["<Leader>IM"] = function()
  utils.ColorMyPencils()
end

nnoremap["<leader>aR"] = function()
  utils.EmptyRegisters()
end

nnoremap["<Leader>a;"] = function()
  utils.OpenTerminal()
end

nnoremap["<leader>ao"] = function()
  utils.TurnOnGuides()
end

nnoremap["<leader>ae"] = function()
  utils.TurnOffGuides()
end

-----------------------------------------------------------------------------//
-- Plugins
-----------------------------------------------------------------------------//

-- TAB in general mode will move to next buffer, SHIFT-TAB will go back
if not rvim.plugin.bufferline.active then
  nnoremap["<TAB>"] = ":bnext<CR>"
  nnoremap["<S-TAB>"] = ":bprevious<CR>"
end

if not rvim.plugin_loaded "accelerated-jk.nvim" then
  nnoremap["n"] = "j"
end

-- Vsnip
if rvim.plugin.vsnip.active then
  xnoremap["<C-x>"] = { "<Plug>(vsnip-cut-text)", { noremap = false, silent = true } }
  xnoremap["<C-l>"] = { "<Plug>(vsnip-select-text)", { noremap = false, silent = true } }
  nnoremap["<leader>cs"] = ":VsnipOpen<CR> 1<CR><CR>"
  rvim.keys.inoremap["<C-l>"] = {
    "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
    { noremap = false, silent = true, expr = true },
  }
  rvim.keys.snoremap["<C-l>"] = {
    "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
    { noremap = false, silent = true, expr = true },
  }
end

if rvim.plugin.dial.active then
  nnoremap["<C-a>"] = { "<Plug>(dial-increment)", { noremap = false, silent = true } }
  nnoremap["<C-x>"] = { "<Plug>(dial-decrement)", { noremap = false, silent = true } }
  vnoremap["<C-a>"] = { "<Plug>(dial-increment)", { noremap = false, silent = true } }
  vnoremap["<C-x>"] = { "<Plug>(dial-decrement)", { noremap = false, silent = true } }
  vnoremap["g<C-a>"] = { "<Plug>(dial-increment-additional)", { noremap = false, silent = true } }
  vnoremap["g<C-x>"] = { "<Plug>(dial-decrement-additional)", { noremap = false, silent = true } }
end

if rvim.plugin.surround.active then
  xnoremap["S"] = { "<Plug>VSurround", { noremap = false, silent = true } }
  xnoremap["S"] = { "<Plug>VSurround", { noremap = false, silent = true } }
end

if rvim.plugin.kommentary.active then
  xnoremap["<leader>/"] = { "<Plug>kommentary_visual_default", { noremap = false, silent = true } }
end

if rvim.plugin.bufferline.active then
  nnoremap["<Leader>bn"] = ":BufferLineMoveNext<CR>"
  nnoremap["<Leader>bb"] = ":BufferLineMovePrev<CR>"
  nnoremap["<TAB>"] = ":BufferLineCycleNext<CR>"
  nnoremap["<S-TAB>"] = ":BufferLineCyclePrev<CR>"
  nnoremap["gb"] = ":BufferLinePick<CR>"
end

if rvim.plugin.fterm.active then
  nnoremap["<F12>"] = '<cmd>lua require("FTerm").toggle()<CR>'
  tnoremap["<F12>"] = '<C-\\><C-n><cmd>lua require("FTerm").toggle()<CR>'
  nnoremap["<leader>en"] = '<cmd>lua require("FTerm").open()<CR>'
end

-- TODO: COnvert mappings below to use new format
if rvim.plugin.easy_align.active then
  local nmap = rvim.nmap
  local xmap = rvim.xmap
  local vmap = rvim.vmap
  vmap("<Enter>", "<Plug>(EasyAlign)")
  nmap("ga", "<Plug>(EasyAlign)")
  xmap("ga", "<Plug>(EasyAlign)")
end

if rvim.plugin.eft.active then
  local xmap = rvim.xmap
  local nmap = rvim.nmap
  local omap = rvim.omap
  local opts = { expr = true }
  nmap(";", "v:lua.enhance_ft_move(';')", opts)
  xmap(";", "v:lua.enhance_ft_move(';')", opts)
  nmap("f", "v:lua.enhance_ft_move('f')", opts)
  xmap("f", "v:lua.enhance_ft_move('f')", opts)
  omap("f", "v:lua.enhance_ft_move('f')", opts)
  nmap("F", "v:lua.enhance_ft_move('F')", opts)
  xmap("F", "v:lua.enhance_ft_move('F')", opts)
  omap("F", "v:lua.enhance_ft_move('F')", opts)
end
