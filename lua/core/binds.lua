local g = vim.g
local u = require "utils"

local M = {}

rvim.keys = {
  ---@usage change or add keymappings for normal mode
  normal_mode = {
    -- Yank from cursor position to end-of-line
    ["Y"] = "y$",

    -- Easy way to close popups windows
    ["W"] = "q",

    -- Open url
    ["gx"] = ":sil !xdg-open <c-r><c-a><cr>",

    -- Repeat last substitute with flags
    ["&"] = "<cmd>&&<CR>",

    -- Zero should go to the first non-blank character not to the first column (which could be blank)
    ["0"] = "^",

    -- Map Q to replay q register
    ["Q"] = "@q",

    -- Undo
    ["<C-z>"] = ":undo<CR>",

    -- remap esc to use cc
    ["<C-c>"] = "<Esc>",

    -- QuickRun
    ["<C-b>"] = ":QuickRun<CR>",
  },
  ---@usage change or add keymappings for insert mode
  insert_mode = {
    -- Start new line from any cursor position
    ["<S-Return>"] = "<C-o>o",
  },
  ---@usage change or add keymappings for terminal mode
  term_mode = {},
  ---@usage change or add keymappings for visual mode
  visual_mode = {
    -- Better indenting
    ["<"] = "<gv",
    [">"] = ">gv",

    -- search visual selection
    ["//"] = [[y/<C-R>"<CR>]],

    -- find visually selected text
    ["*"] = [[y/<C-R>"<CR>]],

    -- make . work with visually selected lines
    ["."] = ":norm.<CR>",

    -- when going to the end of the line in visual mode ignore whitespace characters
    ["$"] = "g_",
  },
  ---@usage change or add keymappings for visual block mode
  visual_block_mode = {
    -- Move selected line / block of text in visual mode
    ["K"] = ":m '<-2<CR>gv=gv",
    ["N"] = ":m '>+1<CR>gv=gv",

    -- Paste in visual mode multiple times
    ["p"] = "pgvy",

    -- Repeat last substitute with flags
    ["&"] = "<cmd>&&<CR>",
  },
  ---@usage change or add keymappings for command mode
  command_mode = {
    -- Smart mappings on the command line
    ["w!!"] = [[w !sudo tee % >/dev/null]],

    -- insert path of current file into a command
    ["%%"] = "<C-r>=fnameescape(expand('%'))<cr>",
    ["::"] = "<C-r>=fnameescape(expand('%:p:h'))<cr>/",
  },
}

local mode_adapters = {
  insert_mode = "i",
  normal_mode = "n",
  term_mode = "t",
  visual_mode = "v",
  visual_block_mode = "x",
  command_mode = "c",
}
-- Set key mappings individually
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param key The key of keymap
-- @param val Can be form as a mapping or tuple of mapping and user defined opt
function M.set_keymaps(mode, key, val)
  local nnoremap = rvim.nnoremap
  local xnoremap = rvim.xnoremap
  local vnoremap = rvim.vnoremap
  local inoremap = rvim.inoremap
  local tnoremap = rvim.tnoremap
  local cnoremap = rvim.cnoremap
  if type(val) == "table" then
    local opt = val[2]
    val = val[1]
    local custom_map = rvim.make_mapper(mode, opt)
    custom_map(key, val)
    return
  end
  if mode == "i" then
    inoremap(key, val)
  elseif mode == "n" then
    nnoremap(key, val)
  elseif mode == "t" then
    tnoremap(key, val)
  elseif mode == "v" then
    vnoremap(key, val)
  elseif mode == "x" then
    xnoremap(key, val)
  elseif mode == "c" then
    cnoremap(key, val)
  end
end

-- Load key mappings for a given mode
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param keymaps The list of key mappings
function M.load_mode(mode, keymaps)
  mode = mode_adapters[mode] and mode_adapters[mode] or mode
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

function M.setup()
  g.mapleader = (rvim.common.leader == "space" and " ") or rvim.common.leader
  g.maplocalleader = (rvim.common.leader == "space" and " ") or rvim.common.leader
  M.load(rvim.keys)
end

local normal_mode, command_mode, insert_mode, visual_mode, term_mode =
  rvim.keys.normal_mode, rvim.keys.command_mode, rvim.keys.insert_mode, rvim.keys.visual_mode, rvim.keys.term_mode

-- TAB in general mode will move to text buffer, SHIFT-TAB will go back
if not rvim.plugin.SANE.active then
  normal_mode["<TAB>"] = ":bnext<CR>"
  normal_mode["<S-TAB>"] = ":bprevious<CR>"
end

-- Better Navigation
normal_mode["<C-h>"] = "<C-w>h"
normal_mode["<C-n>"] = "<C-w>j"
normal_mode["<C-k>"] = "<C-w>k"
normal_mode["<C-l>"] = "<C-w>l"

-- Use alt + hjkl to resize windows
normal_mode["<M-n>"] = ":resize -2<CR>"
normal_mode["<M-k>"] = ":resize +2<CR>"
normal_mode["<M-h>"] = ":vertical resize +2<CR>"
normal_mode["<M-l>"] = ":vertical resize -2<CR>"

-- Window Resize
normal_mode["<Leader>ca"] = ":vertical resize 40<CR>"
normal_mode["<Leader>aF"] = ":vertical resize 90<CR>"

-- Search Files
normal_mode["<Leader>chw"] = ':h <C-R>=expand("<cword>")<CR><CR>'
normal_mode["<Leader>bs"] = '/<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>'

-- Add Empty space above and below
normal_mode["[<space>"] = [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]]
normal_mode["]<space>"] = [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]]

-- Tab navigation
normal_mode["<Leader>sb"] = ":tabprevious<CR>"
normal_mode["<Leader>sK"] = ":tablast<CR>"
normal_mode["<Leader>sk"] = ":tabfirst<CR>"
normal_mode["<Leader>sn"] = ":tabnext<CR>"
normal_mode["<Leader>sN"] = ":tabnew<CR>"
normal_mode["<Leader>sd"] = ":tabclose<CR>"
normal_mode["<Leader>sH"] = ":-tabmove<CR>"
normal_mode["<Leader>sL"] = ":+tabmove<CR>"

-- Alternate way to quit
normal_mode["<Leader>ax"] = ":wq!<CR>"
normal_mode["<Leader>az"] = ":q!<CR>"
normal_mode["<Leader>x"] = ":q<CR>"

-- Disable arrows in normal mode
normal_mode["<down>"] = "<nop>"
normal_mode["<up>"] = "<nop>"
normal_mode["<left>"] = "<nop>"
normal_mode["<right>"] = "<nop>"

-- Greatest remap ever
visual_mode["<Leader>p"] = '"_dP'

-- Next greatest remap ever : asbjornHaland
visual_mode["<Leader>y"] = '"+y'
normal_mode["<Leader>y"] = '"+y'

-- Whole file delete yank, paste
normal_mode["<Leader>aY"] = 'gg"+yG'
normal_mode["<Leader>aV"] = 'gg"+VG'
normal_mode["<Leader>aD"] = 'gg"+VGd'

-- actions
normal_mode["<Leader>="] = "<C-W>="
normal_mode["<Leader>ah"] = "<C-W>s"
normal_mode["<Leader>av"] = "<C-W>v"
normal_mode["<Leader>ad"] = ":bdelete!<CR>"

-- opens the last buffer
normal_mode["<leader>al"] = "<C-^>"

-- Folds
normal_mode["<S-Return>"] = "zMzvzt"
normal_mode["<Leader>afr"] = "zA" -- Recursively toggle
normal_mode["<Leader>afl"] = "za" -- Toggle fold under the cursor
normal_mode["<Leader>afo"] = "zR" -- Open all folds
normal_mode["<Leader>afx"] = "zM" -- Close all folds
normal_mode["<Leader>aO"] = ":<C-f>:resize 10<CR>" -- Close all folds

-- Conditionally modify character at end of line
normal_mode["<localleader>,"] = "<cmd>call utils#modify_line_end_delimiter(',')<cr>"
normal_mode["<localleader>;"] = "<cmd>call utils#modify_line_end_delimiter(';')<cr>"
normal_mode["<localleader>."] = "<cmd>call utils#modify_line_end_delimiter('.')<cr>"

-- qflist
normal_mode["<Leader>vo"] = ":copen<CR>"

-- Change two horizontally split windows to vertical splits
normal_mode["<localleader>wv"] = "<C-W>t <C-W>H<C-W>="
-- Change two vertically split windows to horizontal splits
normal_mode["<localleader>wh"] = "<C-W>t <C-W>K<C-W>="
-- opens a vertical split
normal_mode["<Leader>av"] = "<C-W>vgf"
-- opens a horizontal split
normal_mode["<Leader>ah"] = "<C-W>s"

-- Quick find/replace
local noisy = { silent = false }
normal_mode["<leader>["] = { [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy }
normal_mode["<leader>]"] = { [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy }
normal_mode["<leader>["] = { [["zy:%s/<C-r><C-o>"/]], noisy }

-- open a new file in the same directory
normal_mode["<leader>nf"] = { [[:e <C-R>=expand("%:p:h") . "/" <CR>]], { silent = false } }
-- create a new file in the same directory
normal_mode["<leader>ns"] = { [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]], { silent = false } }

-- This line opens the vimrc in a vertical split
normal_mode["<leader>Iv"] = ":e ~/.config/rvim/init.lua<CR>"

-- This line opens the core/init.lua file
normal_mode["<leader>Ic"] = ":e ~/.config/rvim/lua/core/init.lua<CR>"

-- Quotes
normal_mode['<leader>"'] = [[ciw"<c-r>""<esc>]]
normal_mode["<leader>`"] = [[ciw`<c-r>"`<esc>]]
normal_mode["<leader>'"] = [[ciw'<c-r>"'<esc>]]
normal_mode["<leader>)"] = [[ciw(<c-r>")<esc>]]
normal_mode["<leader>}"] = [[ciw{<c-r>"}<esc>]]

-- Other remaps
normal_mode["<Leader>aL"] = ":e ~/.config/rvim/external/utils/.vimrc.local<CR>"

-- Neovim Health check
normal_mode["<Leader>IC"] = ":checkhealth<CR>"
normal_mode["<Leader>Im"] = ":messages<CR>"

-- Buffers
normal_mode["<Leader><Leader>"] = ":call v:lua.DelThisBuffer()<CR>"
normal_mode["<Leader>bdh"] = ":call v:lua.DelToLeft()<CR>"
normal_mode["<Leader>bda"] = ":call v:lua.DelAllBuffers()<CR>"
normal_mode["<Leader>bdx"] = ":call v:lua.DelAllExceptCurrent()<CR>"

-- Disable arrows in insert mode
insert_mode["<down>"] = "<nop>"
insert_mode["<up>"] = "<nop>"
insert_mode["<left>"] = "<nop>"
insert_mode["<right>"] = "<nop>"

-- https://github.com/tpope/vim-rsi/blob/master/plugin/rsi.vim
-- c-a / c-e everywhere - RSI.vim provides these
command_mode["<C-j>"] = "<Down>"
command_mode["<C-p>"] = "<Up>"

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
command_mode["<Tab>"] = { [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>/<C-r>/" : "<C-z>"]], { expr = true } }
command_mode["<S-Tab>"] = {
  [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>?<C-r>/" : "<S-Tab>"]],
  { expr = true },
}

-- Alternate way to save
normal_mode["<C-s>"] = function()
  u.save_and_notify()
end

-- toggle_list
normal_mode["<leader>ls"] = function()
  u.toggle_list "c"
end

normal_mode["<leader>li"] = function()
  u.toggle_list "l"
end

normal_mode["<Leader>vwm"] = function()
  u.ColorMyPencils()
end

normal_mode["<leader>aR"] = function()
  u.EmptyRegisters()
end

normal_mode["<Leader>a;"] = function()
  u.OpenTerminal()
end

normal_mode["<leader>ao"] = function()
  u.TurnOnGuides()
end

normal_mode["<leader>ae"] = function()
  u.TurnOffGuides()
end

-- if the file under the cursor doesn't exist create it
-- see :h gf a simpler solution of :edit <cfile> is recommended but doesn't work.
-- If you select require('buffers/file') in lua for example
-- this makes the cfile -> buffers/file rather than my_dir/buffer/file.lua
-- Credit: 1,2
normal_mode["gf"] = function()
  u.open_file_or_create_new()
end

-- GX - replicate netrw functionality
normal_mode["gX"] = function()
  u.open_link()
end

-- Terminal {{{
rvim.augroup("AddTerminalMappings", {
  {
    events = { "TermOpen" },
    targets = { "*:zsh" },
    command = function()
      if vim.bo.filetype == "" or vim.bo.filetype == "toggleterm" then
        local opts = { silent = false, buffer = 0 }
        term_mode["<esc>"] = { [[<C-\><C-n>:q!<CR>]], opts }
        term_mode["jk"] = { [[<C-\><C-n>]], opts }
        term_mode["<C-h>"] = { [[<C-\><C-n><C-W>h]], opts }
        term_mode["<C-j>"] = { [[<C-\><C-n><C-W>j]], opts }
        term_mode["<C-k>"] = { [[<C-\><C-n><C-W>k]], opts }
        term_mode["<C-l>"] = { [[<C-\><C-n><C-W>l]], opts }
        term_mode["]t"] = { [[<C-\><C-n>:tablast<CR>]] }
        term_mode["[t"] = { [[<C-\><C-n>:tabnext<CR>]] }
        term_mode["<S-Tab>"] = { [[<C-\><C-n>:bprev<CR>]] }
        term_mode["<leader><Tab>"] = { [[<C-\><C-n>:close \| :bnext<cr>]] }
      end
    end,
  },
})

if not rvim.plugin.accelerated_jk.active and not rvim.plugin.SANE.active then
  local nmap = rvim.nmap
  nmap("n", "j")
end

vim.cmd [[vnoremap <Leader>rev :s/\%V.\+\%V./\=utils#rev_str(submatch(0))<CR>gv]]

return M
