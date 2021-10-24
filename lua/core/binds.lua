local g = vim.g
local u = require "utils"

local M = {}

rvim.keys = {
  ---@usage change or add keymappings for normal mode
  normal_mode = {
    -- Yank from cursor position to end-of-line
    ["Y"] = "y$",

    -- Easy way to close popups windows
    ["W"] = { "q", { noremap = false, silent = true } },

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

    -- Better window movement
    ["<C-h>"] = "<C-w>h",
    ["<C-n>"] = "<C-w>j",
    ["<C-k>"] = "<C-w>k",
    ["<C-l>"] = "<C-w>l",

    -- Move current line / block with Alt-j/k a la vscode.
    ["<A-j>"] = ":m .+1<CR>==",
    ["<A-k>"] = ":m .-2<CR>==",

    -- Use alt + hjkl to resize windows
    ["<M-n>"] = ":resize -2<CR>",
    ["<M-k>"] = ":resize +2<CR>",
    ["<M-h>"] = ":vertical resize +2<CR>",
    ["<M-l>"] = ":vertical resize -2<CR>",

    -- Add Empty space above and below
    ["[<space>"] = [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]],
    ["]<space>"] = [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]],

    -- Disable arrows in normal mode
    ["<down>"] = "<nop>",
    ["<up>"] = "<nop>",
    ["<left>"] = "<nop>",
    ["<right>"] = "<nop>",
  },
  ---@usage change or add keymappings for insert mode
  insert_mode = {
    -- Start new line from any cursor position
    ["<S-Return>"] = "<C-o>o",

    -- Disable arrows in insert mode
    ["<down>"] = "<nop>",
    ["<up>"] = "<nop>",
    ["<left>"] = "<nop>",
    ["<right>"] = "<nop>",
  },
  ---@usage change or add keymappings for terminal mode
  term_mode = {
    -- ["<esc>"] = "<C-\\><C-n>:q!<CR>",
    ["jk"] = "<C-\\><C-n>",
    ["<C-h>"] = "<C-\\><C-n><C-W>h",
    ["<C-j>"] = "<C-\\><C-n><C-W>j",
    ["<C-k>"] = "<C-\\><C-n><C-W>k",
    ["<C-l>"] = "<C-\\><C-n><C-W>l",
    ["]t"] = "<C-\\><C-n>:tablast<CR>",
    ["[t"] = "<C-\\><C-n>:tabnext<CR>",
    ["<S-Tab>"] = "<C-\\><C-n>:bprev<CR>",
  },
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
    -- smooth searching, allow tabbing between search results similar to using <c-g>
    -- or <c-t> the main difference being tab is easier to hit and remapping those keys
    -- to these would swallow up a tab mapping
    ["<Tab>"] = { [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>/<C-r>/" : "<C-z>"]], { expr = true } },
    ["<S-Tab>"] = { [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>?<C-r>/" : "<S-Tab>"]], { expr = true } },
  },
}

local generic_opts_any = { noremap = true, silent = true }

local generic_opts = {
  insert_mode = generic_opts_any,
  normal_mode = generic_opts_any,
  term_mode = { silent = true },
  command_mode = { noremap = true, silent = false },
  visual_mode = generic_opts_any,
  visual_block_mode = generic_opts_any,
}

local mode_adapters = {
  insert_mode = "i",
  normal_mode = "n",
  term_mode = "t",
  command_mode = "c",
  visual_mode = "v",
  visual_block_mode = "x",
}
-- Set key mappings individually
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param key The key of keymap
-- @param val Can be form as a mapping or tuple of mapping and user defined opt
function M.set_keymaps(mode, key, val)
  local opt = generic_opts[mode] and generic_opts[mode] or generic_opts_any
  if type(val) == "table" then
    opt = val[2]
    val = val[1]
  end

  local custom_map = rvim.make_mapper(mode, opt)
  custom_map(key, val)
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

local normal_mode, term_mode, visual_mode = rvim.keys.normal_mode, rvim.keys.term_mode, rvim.keys.visual_mode

-- TAB in general mode will move to text buffer, SHIFT-TAB will go back
if rvim.plugin.ajk.active == false then
  normal_mode["<TAB>"] = ":bnext<CR>"
  normal_mode["<S-TAB>"] = ":bprevious<CR>"
end

-- Window Resize
normal_mode["<Leader>ca"] = ":vertical resize 40<CR>"
normal_mode["<Leader>aF"] = ":vertical resize 90<CR>"

-- Search Files
normal_mode["<Leader>chw"] = ':h <C-R>=expand("<cword>")<CR><CR>'
normal_mode["<Leader>bs"] = '/<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>'

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

-- Greatest remap ever
visual_mode["<Leader>p"] = '"_dP'

-- Next greatest remap ever : asbjornHaland
normal_mode["<Leader>y"] = '"+y'
visual_mode["<Leader>y"] = '"+y'

-- Whole file delete yank, paste
normal_mode["<Leader>aY"] = 'gg"+yG'
normal_mode["<Leader>aV"] = 'gg"+VG'
normal_mode["<Leader>aD"] = 'gg"+VGd'

-- actions
-- normal_mode["<Leader>="] = "<C-W>="
-- opens a horizontal split
-- normal_mode["<Leader>ah"] = "<C-W>s"
-- opens a vertical split
normal_mode["<Leader>av"] = "<C-W>vgf"
-- Change two horizontally split windows to vertical splits
normal_mode["<localleader>wv"] = "<C-W>t <C-W>H<C-W>="
-- Change two vertically split windows to horizontal splits
normal_mode["<localleader>wh"] = "<C-W>t <C-W>K<C-W>="
-- delete buffer
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
normal_mode["<Leader>oe"] = ":copen<CR>"
normal_mode["<Leader>vo"] = ":copen<CR>"

-- Quick find/replace
local nnoremap, vnoremap, cnoremap = rvim.nnoremap, rvim.vnoremap, rvim.cnoremap
local noisy = { silent = false }
nnoremap("<leader>[", [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy)
nnoremap("<leader>]", [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy)
vnoremap("<leader>[", [["zy:%s/<C-r><C-o>"/]], noisy)

-- Smart mappings on the command line
cnoremap("w!!", [[w !sudo tee % >/dev/null]])
-- insert path of current file into a command
cnoremap("%%", "<C-r>=fnameescape(expand('%'))<cr>")
cnoremap("::", "<C-r>=fnameescape(expand('%:p:h'))<cr>/")

-- open a new file in the same directory
normal_mode["<leader>nf"] = { [[:e <C-R>=expand("%:p:h") . "/" <CR>]], noisy }
-- create a new file in the same directory
normal_mode["<leader>ns"] = { [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]], noisy }

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

-- Terminal mode
term_mode["<leader><Tab>"] = [[<C-\><C-n>:close \| :bnext<cr>]]

-- Alternate way to save
normal_mode["<C-s>"] = function()
  u.save_and_notify()
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

-- toggle_list
normal_mode["<leader>ls"] = function()
  u.toggle_list "c"
end

normal_mode["<leader>li"] = function()
  u.toggle_list "l"
end

normal_mode["<Leader>IM"] = function()
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

if not rvim.plugin.ajk.active then
  local nmap = rvim.nmap
  nmap("n", "j")
end

vim.cmd [[vnoremap <Leader>rev :s/\%V.\+\%V./\=utils#rev_str(submatch(0))<CR>gv]]

return M
