local defaults = rvim.keymaps
local utils = require "user.utils"

local nmap = defaults.nmap
local vmap = defaults.vmap
local xmap = defaults.xmap
local nnoremap = defaults.nnoremap
local cnoremap = defaults.cnoremap
local tnoremap = defaults.tnoremap
local vnoremap = defaults.vnoremap
local xnoremap = defaults.xnoremap
local inoremap = defaults.inoremap

-----------------------------------------------------------------------------//
-- Defaults
-----------------------------------------------------------------------------//

-- Undo
nnoremap["<C-z>"] = ":undo<CR>"
vnoremap["<C-z>"] = ":undo<CR><Esc>"
xnoremap["<C-z>"] = ":undo<CR><Esc>"

-- undo command in insert mode
inoremap["<c-z>"] = function()
  vim.cmd [[:undo]]
end

-- remap esc to use cc
nnoremap["<C-c>"] = "<Esc>"

-- Better window movement
nnoremap["<C-h>"] = "<C-w>h"
nnoremap["<C-j>"] = "<C-w>j"
nnoremap["<C-k>"] = "<C-w>k"
nnoremap["<C-l>"] = "<C-w>l"

-- Move current line / block with Alt-j/k a la vscode.
nnoremap["<A-j>"] = ":m .+1<CR>=="
nnoremap["<A-k>"] = ":m .-2<CR>=="

-- Disable arrows in normal mode
nnoremap["<down>"] = "<nop>"
nnoremap["<up>"] = "<nop>"
nnoremap["<left>"] = "<nop>"
nnoremap["<right>"] = "<nop>"

-- Move selected line / block of text in visual mode
xnoremap["K"] = ":m '<-2<CR>gv=gv"
xnoremap["J"] = ":m '>+1<CR>gv=gv"

-- Add Empty space above and below
nnoremap["[<space>"] = [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]]
nnoremap["]<space>"] = [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]]

-- Paste in visual mode multiple times
xnoremap["p"] = "pgvy"

-- Repeat last substitute with flags
xnoremap["&"] = "<cmd>&&<CR>"

-- Start new line from any cursor position
inoremap["<S-Return>"] = "<C-o>o"

-- Better indenting
vnoremap["<"] = "<gv"
vnoremap[">"] = ">gv"

-- search visual selection
vnoremap["//"] = [[y/<C-R>"<CR>]]

-- Capitalize
nnoremap["<leader>U"] = "gUiw`]"
inoremap["<C-u>"] = "<cmd>norm!gUiw`]a<CR>"

-- Credit: Justinmk
nnoremap["g>"] = [[<cmd>set nomore<bar>40messages<bar>set more<CR>]]

-- find visually selected text
vnoremap["*"] = [[y/<C-R>"<CR>]]

-- make . work with visually selected lines
vnoremap["."] = ":norm.<CR>"

-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap["$"] = "g_"

tnoremap["<esc>"] = "<C-\\><C-n>:q!<CR>"
tnoremap["jk"] = "<C-\\><C-n>"
tnoremap["<C-h>"] = "<C\\><C-n><C-W>h"
tnoremap["<C-j>"] = "<C-\\><C-n><C-W>j"
tnoremap["<C-k>"] = "<C-\\><C-n><C-W>k"
tnoremap["<C-l>"] = "<C-\\><C-n><C-W>l"
tnoremap["]t"] = "<C-\\><C-n>:tablast<CR>"
tnoremap["[t"] = "<C-\\><C-n>:tabnext<CR>"
tnoremap["<S-Tab>"] = "<C-\\><C-n>:bprev<CR>"

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
cnoremap["<Tab>"] = {
  [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>/<C-r>/" : "<C-z>"]],
  { expr = true },
}
cnoremap["<S-Tab>"] = {
  [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>?<C-r>/" : "<S-Tab>"]],
  { expr = true },
}

-- Use alt + hjkl to resize windows
nnoremap["<M-j>"] = ":resize -2<CR>"
nnoremap["<M-k>"] = ":resize +2<CR>"
nnoremap["<M-l>"] = ":vertical resize -2<CR>"
nnoremap["<M-h>"] = ":vertical resize +2<CR>"

-- Yank from cursor position to end-of-line
nnoremap["Y"] = "y$"

-- Repeat last substitute with flags
nnoremap["&"] = "<cmd>&&<CR>"

-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap["0"] = { "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true } }

-- Map Q to replay q register
nnoremap["Q"] = "@q"

-----------------------------------------------------------------------------//
-- Multiple Cursor Replacement
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
-----------------------------------------------------------------------------//
nnoremap["cn"] = "*``cgn"
nnoremap["cN"] = "*``cgN"

-- Add Empty space above and below
nnoremap["[<space>"] = [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]]
nnoremap["]<space>"] = [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]]

-- Smart mappings on the command line
cnoremap["w!!"] = [[w !sudo tee % >/dev/null]]

-- insert path of current file into a command
cnoremap["%%"] = "<C-r>=fnameescape(expand('%'))<cr>"
cnoremap["::"] = "<C-r>=fnameescape(expand('%:p:h'))<cr>/"

------------------------------------------------------------------------------
-- Credit: June Gunn <Leader>?/! | Google it / Feeling lucky
------------------------------------------------------------------------------
local fn = vim.fn
function rvim.mappings.google(pat, lucky, gh)
  local query = '"' .. fn.substitute(pat, '["\n]', " ", "g") .. '"'
  query = fn.substitute(query, "[[:punct:] ]", [[\=printf("%%%02X", char2nr(submatch(0)))]], "g")
  if gh then
    fn.system(
      fn.printf(
        rvim.open_command .. ' "https://github.com/search?%sq=%s"',
        lucky and "btnI&" or "",
        query
      )
    )
  else
    fn.system(
      fn.printf(
        rvim.open_command .. ' "https://html.duckduckgo.com/html?%sq=%s"',
        lucky and "btnI&" or "",
        query
      )
    )
  end
end

-- Searcg DuckDuckGo
nnoremap["<leader>?"] = [[:lua rvim.mappings.google(vim.fn.expand("<cword>"), false, false)<cr>]]
nnoremap["<leader>!"] = [[:lua rvim.mappings.google(vim.fn.expand("<cword>"), true, false)<cr>]]
xnoremap["<leader>?"] =
  [["gy:lua rvim.mappings.google(vim.api.nvim_eval("@g"), false, false)<cr>gv]]
xnoremap["<leader>!"] =
  [["gy:lua rvim.mappings.google(vim.api.nvim_eval("@g"), false, false)<cr>gv]]

-- Search Github
nnoremap["<leader>L?"] = [[:lua rvim.mappings.google(vim.fn.expand("<cword>"), false, true)<cr>]]
nnoremap["<leader>L!"] = [[:lua rvim.mappings.google(vim.fn.expand("<cword>"), false, true)<cr>]]
xnoremap["<leader>L?"] =
  [["gy:lua rvim.mappings.google(vim.api.nvim_eval("@g"), false, true)<cr>gv]]
xnoremap["<leader>L!"] =
  [["gy:lua rvim.mappings.google(vim.api.nvim_eval("@g"), false, true, true)<cr>gv]]

-- QuickRun
nnoremap["<C-b>"] = ":QuickRun<CR>"

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

-- Open url
-- nnoremap["gx"] = ":sil !xdg-open <c-r><c-a><cr>"

-- replicate netrw functionality
nnoremap["gx"] = function()
  utils.open_link()
end

-----------------------------------------------------------------------------//
-- Leader keymap
-----------------------------------------------------------------------------//

-- toggle_list
nnoremap["<leader>lW"] = function()
  rvim.toggle_list "quickfix"
end

nnoremap["<leader>lL"] = function()
  rvim.toggle_list "location"
end

nnoremap["<Leader>LM"] = function()
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

-- Search Files
nnoremap["<Leader>B"] = '/<C-R>=escape(expand("<cword>"), "/")<CR><CR>'

-- Greatest remap ever
vnoremap["<Leader>p"] = '"_dP'

-- Reverse Line
vnoremap["<Leader>r"] = [[:s/\%V.\+\%V./\=utils#rev_str(submatch(0))<CR>gv]]

-- Next greatest remap ever : asbjornHaland
nnoremap["<Leader>y"] = '"+y'
vnoremap["<Leader>y"] = '"+y'

-- Whole file delete yank, paste
nnoremap["<Leader>A"] = 'gg"+VG'
nnoremap["<Leader>D"] = 'gg"+VGd'
nnoremap["<Leader>Y"] = 'gg"+yG'

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

-- opens the last buffer
nnoremap["<leader>al"] = "<C-^>"

-- Folds
nnoremap["<S-Return>"] = "zMzvzt"
nnoremap["<Leader>afr"] = "zA" -- Recursively toggle
nnoremap["<Leader>afl"] = "za" -- Toggle fold under the cursor
nnoremap["<Leader>afo"] = "zR" -- Open all folds
nnoremap["<Leader>afx"] = "zM" -- Close all folds

-- Conditionally modify character at end of line
nnoremap["<localleader>,"] = "<cmd>call utils#modify_line_end_delimiter(',')<cr>"
nnoremap["<localleader>;"] = "<cmd>call utils#modify_line_end_delimiter(';')<cr>"
nnoremap["<localleader>."] = "<cmd>call utils#modify_line_end_delimiter('.')<cr>"

-- Quick find/replace
local noisy = { silent = false }
nnoremap["<leader>["] = { [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy }
nnoremap["<leader>]"] = { [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy }
vnoremap["<leader>["] = { [["zy:%s/<C-r><C-o>"/]], noisy }

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

-- Buffers
nnoremap["<Leader>bc"] = ":call v:lua.DelAllExceptCurrent()<CR>"

-----------------------------------------------------------------------------//
-- Plugins
-----------------------------------------------------------------------------//

-- Bufferlline
if rvim.plugin.bufferline.active then
  nnoremap["<S-l>"] = ":BufferLineCycleNext<CR>"
  nnoremap["<S-h>"] = ":BufferLineCyclePrev<CR>"
  nnoremap["gb"] = ":BufferLinePick<CR>"
else
  nnoremap["<S-l>"] = ":bnext<CR>"
  nnoremap["<S-h>"] = ":bprevious<CR>"
end

-- Vsnip
if rvim.plugin.vsnip.active then
  xmap["<C-x>"] = "<Plug>(vsnip-cut-text)"
  xmap["<C-l>"] = "<Plug>(vsnip-select-text)"
  nnoremap["<leader>S"] = ":VsnipOpen<CR> 1<CR><CR>"
  defaults.imap["<C-l>"] = {
    "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
    { expr = true },
  }
  defaults.smap["<C-l>"] = {
    "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
    { expr = true },
  }
end

-- Dial
if rvim.plugin.dial.active then
  nmap["<C-a>"] = "<Plug>(dial-increment)"
  nmap["<C-x>"] = "<Plug>(dial-decrement)"
  vmap["<C-a>"] = "<Plug>(dial-increment)"
  vmap["<C-x>"] = "<Plug>(dial-decrement)"
  vmap["g<C-a>"] = "<Plug>(dial-increment-additional)"
  vmap["g<C-x>"] = "<Plug>(dial-decrement-additional)"
end

-- surround
if rvim.plugin.surround.active then
  xmap["S"] = "<Plug>VSurround"
  xmap["S"] = "<Plug>VSurround"
end

-- Kommentary
if rvim.plugin.kommentary.active then
  xmap["<leader>/"] = "<Plug>kommentary_visual_default"
end

-- FTerm
if rvim.plugin.fterm.active then
  nnoremap["<F12>"] = '<cmd>lua require("FTerm").toggle()<CR>'
  tnoremap["<F12>"] = '<C-\\><C-n><cmd>lua require("FTerm").toggle()<CR>'
end

-- WhichKey
if rvim.plugin.vim_which_key.active then
  nnoremap["<leader>"] = ':<c-u> :WhichKey "<space>"<CR>'
  nnoremap["<localleader>"] = ':<c-u> :WhichKey "<space>"<CR>'
  vnoremap["<leader>"] = ':<c-u> :WhichKeyVisual "<space>"<CR>'
end

-- easy_align
if rvim.plugin.easy_align.active then
  nmap["ga"] = "<Plug>(EasyAlign)"
  xmap["ga"] = "<Plug>(EasyAlign)"
  vmap["<Enter>"] = "<Plug>(EasyAlign)"
end

-- vim-matchup
if rvim.plugin.matchup.active then
  nnoremap["<Leader>vW"] = ":<c-u>MatchupWhereAmI?<CR>"
end

-- nvim-tree
if rvim.plugin.nvimtree.active then
  nnoremap["<Leader>e"] = ":NvimTreeToggle<CR>"
end
