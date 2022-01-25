local defaults = {
  ---@usage change or add keymappings for normal mode
  nmap = {},

  ---@usage change or add keymappings for visual block mode
  xmap = {},

  ---@usage change or add keymappings for insert mode
  imap = {},

  ---@usage change or add keymappings for visual mode
  vmap = {},

  ---@usage change or add keymappings for operator mode
  omap = {},

  ---@usage change or add keymappings for terminal mode
  tmap = {},

  ---@usage change or add keymappings for select mode
  smap = {},

  ---@usage change or add keymappings for command mode
  cmap = {},

  ---@usage change or add keymappings for recursive normal mode
  nnoremap = {},

  ---@usage change or add keymappings for recursive visual block mode
  xnoremap = {},

  ---@usage change or add keymappings for recursive insert mode
  inoremap = {},

  ---@usage change or add keymappings for recursive visual mode
  vnoremap = {},

  ---@usage change or add keymappings for recursive operator mode
  onoremap = {},

  ---@usage change or add keymappings for recursive terminal mode
  tnoremap = {},

  ---@usage change or add keymappings for recursive select mode
  snoremap = {},

  ---@usage change or add keymappings for recursive command mode
  cnoremap = {},
}

local M = {}

local map_opts = { noremap = false, silent = true }
local noremap_opts = { noremap = true, silent = true }

local generic_opts = {
  nmap = map_opts,
  xmap = map_opts,
  imap = map_opts,
  vmap = map_opts,
  omap = map_opts,
  tmap = map_opts,
  smap = map_opts,
  cmap = { noremap = false, silent = false },
  nnoremap = noremap_opts,
  xnoremap = noremap_opts,
  inoremap = noremap_opts,
  vnoremap = noremap_opts,
  onoremap = noremap_opts,
  tnoremap = noremap_opts,
  snoremap = noremap_opts,
  cnoremap = { noremap = true, silent = false },
}

local mode_adapters = {
  nmap = "n",
  xmap = "x",
  imap = "i",
  vmap = "v",
  omap = "o",
  tmap = "t",
  smap = "s",
  cmap = "c",
  nnoremap = "n",
  xnoremap = "x",
  inoremap = "i",
  vnoremap = "v",
  onoremap = "o",
  tnoremap = "t",
  snoremap = "s",
  cnoremap = "c",
}

-- Append key mappings to rvim's defaults for a given mode
-- @param keymaps The table of key mappings containing a list per mode (normal_mode, insert_mode, ..)
function M.append_to_defaults(keymaps)
  for mode, mappings in pairs(keymaps) do
    for k, v in ipairs(mappings) do
      defaults[mode][k] = v
    end
  end
end

-- Set key mappings individually
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param key The key of keymap
-- @param val Can be form as a mapping or tuple of mapping and user defined opt
function M.set_keymaps(mode, key, val)
  local opt = generic_opts[mode]
  if type(val) == "table" then
    opt = val[2]
    val = val[1]
  end

  if type(val) == "function" then
    local fn_id = rvim._create(val)
    val = string.format("<cmd>lua rvim._execute(%s)<CR>", fn_id)
  end

  vim.api.nvim_set_keymap(mode_adapters[mode], key, val, opt)
end

-- Load key mappings for a given mode
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param keymaps The list of key mappings
function M.load_mode(mode, keymaps)
  for k, v in pairs(keymaps) do
    M.set_keymaps(mode, k, v)
  end
end

-- Load key mappings for all provided modes
-- @param keymaps A list of key mappings for each mode
function M.load(keymaps)
  for mode, mapping in pairs(keymaps) do
    M.load_mode(mode, mapping)
  end
end

function M:init()
  local g = vim.g
  g.mapleader = (rvim.common.leader == "space" and " ") or rvim.common.leader
  g.maplocalleader = (rvim.common.localleader == "space" and " ") or rvim.common.localleader
  M.load(defaults)
end

local nmap, vmap, xmap, nnoremap, cnoremap, tnoremap, vnoremap, xnoremap, inoremap, snoremap =
  defaults.nmap,
  defaults.vmap,
  defaults.xmap,
  defaults.nnoremap,
  defaults.cnoremap,
  defaults.tnoremap,
  defaults.vnoremap,
  defaults.xnoremap,
  defaults.inoremap,
  defaults.snoremap

local utils = require "user.utils"

-----------------------------------------------------------------------------//
-- Defaults
-----------------------------------------------------------------------------//

-- Undo
nnoremap["<C-z>"] = ":undo<CR>"

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
xnoremap["N"] = ":m '>+1<CR>gv=gv"

-- Paste in visual mode multiple times
xnoremap["p"] = "pgvy"

-- Repeat last substitute with flags
xnoremap["&"] = "<cmd>&&<CR>"

-- Start new line from any cursor position
inoremap["<S-Return>"] = "<C-o>o"

-- Disable arrows in insert mode
inoremap["<down>"] = "<nop>"
inoremap["<up>"] = "<nop>"
inoremap["<left>"] = "<nop>"
inoremap["<right>"] = "<nop>"

-- Better indenting
vnoremap["<"] = "<gv"
vnoremap[">"] = ">gv"

-- search visual selection
vnoremap["//"] = [[y/<C-R>"<CR>]]

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
nnoremap["<M-h>"] = ":vertical resize +2<CR>"
nnoremap["<M-l>"] = ":vertical resize -2<CR>"

-- Yank from cursor position to end-of-line
nnoremap["Y"] = "y$"

-- Repeat last substitute with flags
nnoremap["&"] = "<cmd>&&<CR>"

-- Zero should go to the first non-blank character not to the first column (which could be blank)
nnoremap["0"] = "^"

-- Map Q to replay q register
nnoremap["Q"] = "@q"

-- Add Empty space above and below
nnoremap["[<space>"] = [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]]
nnoremap["]<space>"] = [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]]

-- Smart mappings on the command line
cnoremap["w!!"] = [[w !sudo tee % >/dev/null]]

-- insert path of current file into a command
cnoremap["%%"] = "<C-r>=fnameescape(expand('%'))<cr>"
cnoremap["::"] = "<C-r>=fnameescape(expand('%:p:h'))<cr>/"

-- QuickRun
nnoremap["<C-b>"] = ":QuickRun<CR>"

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

-- Window Resize
nnoremap["<Leader>aF"] = ":vertical resize 90<CR>"
nnoremap["<Leader>aL"] = ":vertical resize 40<CR>"

-- Search Files
nnoremap["<Leader>cw"] = ':h <C-R>=expand("<cword>")<CR><CR>'
nnoremap["<Leader>bs"] = '/<C-R>=escape(expand("<cword>"), "/")<CR><CR>'

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
vnoremap["<Leader>ap"] = '"_dP'

-- Reverse Line
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

-- force save
nnoremap["<leader>aS"] = ":w!<CR>"

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

-- Health check
nnoremap["<Leader>IC"] = ":checkhealth<CR>"
nnoremap["<Leader>Im"] = ":messages<CR>"

-- Cache profile
nnoremap["<Leader>IL"] = ":LuaCacheProfile<CR>"

-- Buffers
nnoremap["<Leader><Leader>"] = ":call v:lua.DelThisBuffer()<CR>"
nnoremap["<Leader>bdh"] = ":call v:lua.DelToLeft()<CR>"
nnoremap["<Leader>bda"] = ":call v:lua.DelAllBuffers()<CR>"
nnoremap["<Leader>bdx"] = ":call v:lua.DelAllExceptCurrent()<CR>"

-- Terminal mode
tnoremap["<leader><Tab>"] = [[<C-\><C-n>:close \| :bnext<cr>]]

-----------------------------------------------------------------------------//
-- Plugins
-----------------------------------------------------------------------------//

-- Bufferlline
if rvim.plugin.bufferline.active then
  nnoremap["<Leader>bn"] = ":BufferLineMoveNext<CR>"
  nnoremap["<Leader>bb"] = ":BufferLineMovePrev<CR>"
  nnoremap["<TAB>"] = ":BufferLineCycleNext<CR>"
  nnoremap["<S-TAB>"] = ":BufferLineCyclePrev<CR>"
  nnoremap["gb"] = ":BufferLinePick<CR>"
  -- TAB in general mode will move to next buffer, SHIFT-TAB will go back
elseif not rvim.plugin.bufferline.active then
  nnoremap["<TAB>"] = ":bnext<CR>"
  nnoremap["<S-TAB>"] = ":bprevious<CR>"
end

-- Vsnip
if rvim.plugin.vsnip.active then
  xmap["<C-x>"] = "<Plug>(vsnip-cut-text)"
  xmap["<C-l>"] = "<Plug>(vsnip-select-text)"
  nnoremap["<leader>cs"] = ":VsnipOpen<CR> 1<CR><CR>"
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
  nnoremap["<leader>t;"] = '<cmd>lua require("FTerm").open()<CR>'
end

-- WhichKey
if rvim.plugin.which_key.active then
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

-- ts playground
if rvim.plugin.playground.active then
  nnoremap["<leader>aE"] = function()
    utils.inspect_token()
  end
end

-- vim-matchup
if rvim.plugin.matchup.active then
  nnoremap["<Leader>vW"] = ":<c-u>MatchupWhereAmI?<CR>"
end

-- lsp-installer
if rvim.plugin.lsp_installer.active then
  nnoremap["<Leader>LI"] = ":LspInstall "
end

-- nvim-tree
if rvim.plugin.nvimtree.active then
  nnoremap["<Leader>cv"] = ":NvimTreeToggle<CR>"
else
  nnoremap["<Leader>cv"] = ":Sex!<CR> :vertical resize 30<CR>"
end

return M
