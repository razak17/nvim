local nmap = rvim.nmap
local nnoremap = rvim.nnoremap
local xnoremap = rvim.xnoremap
local vnoremap = rvim.vnoremap
local inoremap = rvim.inoremap
local tnoremap = rvim.tnoremap
local cnoremap = rvim.cnoremap

local fn = vim.fn
local api = vim.api

if not rvim.plugin.accelerated_jk.active and not rvim.plugin.SANE.active then
  nmap('n', 'j')
end

-----------------------------------------------------------------------------//
-- Functions
-----------------------------------------------------------------------------//

-----------------------------------------------------------------------------//
-- CREDIT: @Cocophon
-- This function allows you to see the syntax highlight token of the cursor word and that token's links
---> https://github.com/cocopon/pgmnt.vim/blob/master/autoload/pgmnt/dev.vim
-----------------------------------------------------------------------------//
local function hi_chain(syn_id)
  local name = fn.synIDattr(syn_id, "name")
  local names = {}
  table.insert(names, name)
  local original = fn.synIDtrans(syn_id)
  if syn_id ~= original then
    table.insert(names, fn.synIDattr(original, "name"))
  end

  return names
end

local ts_playground_loaded, ts_hl_info
local function inspect_token()
  if not ts_playground_loaded then
    ts_playground_loaded, ts_hl_info = pcall(require, "nvim-treesitter-playground.hl-info")
  end
  if vim.tbl_contains(rvim.treesitter.get_filetypes(), vim.bo.filetype) then
    ts_hl_info.show_hl_captures()
  else
    local syn_id = fn.synID(fn.line("."), fn.col("."), 1)
    local names = hi_chain(syn_id)
    rvim.echomsg(fn.join(names, " -> "))
  end
end

local function save_and_notify()
  vim.cmd("silent write")
  rvim.notify("Saved " .. vim.fn.expand("%:t"), {timeout = 1000})
end

local function open_file_or_create_new()
  local path = fn.expand("<cfile>")
  if not path or path == "" then
    return false
  end

  -- TODO handle terminal buffers

  if pcall(vim.cmd, "norm!gf") then
    return true
  end

  local answer = fn.input("Create a new file, (Y)es or (N)o? ")
  if not answer or string.lower(answer) ~= "y" then
    return vim.cmd "redraw"
  end
  vim.cmd "redraw"
  local new_path = fn.fnamemodify(fn.expand("%:p:h") .. "/" .. path, ":p")
  local ext = fn.fnamemodify(new_path, ":e")

  if ext and ext ~= "" then
    return vim.cmd("edit " .. new_path)
  end

  local suffixes = fn.split(vim.bo.suffixesadd, ",")

  for _, suffix in ipairs(suffixes) do
    if fn.filereadable(new_path .. suffix) then
      return vim.cmd("edit " .. new_path .. suffix)
    end
  end

  return vim.cmd("edit " .. new_path .. suffixes[1])
end

local function open_link()
  local file = fn.expand("<cfile>")
  if fn.isdirectory(file) > 0 then
    vim.cmd("edit " .. file)
  else
    fn.jobstart({vim.g.open_command, file}, {detach = true})
  end
end

local function toggle_list(prefix)
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    local location_list = fn.getloclist(0, {filewinid = 0})
    local is_loc_list = location_list.filewinid > 0
    if vim.bo[buf].filetype == "qf" or is_loc_list then
      fn.execute(prefix .. "close")
      return
    end
  end
  if prefix == "l" and vim.tbl_isempty(fn.getloclist(0)) then
    fn["utils#message"]("Location List is Empty.", "Title")
    return
  end

  local winnr = fn.winnr()
  fn.execute(prefix .. "open")
  if fn.winnr() ~= winnr then
    vim.cmd [[wincmd p]]
  end
end

local function ColorMyPencils()
  vim.cmd [[ hi! ColorColumn guibg=#aeacec ]]
  vim.cmd [[ hi! Normal ctermbg=none guibg=none ]]
  vim.cmd [[ hi! SignColumn ctermbg=none guibg=none ]]
  vim.cmd [[ hi! LineNr guifg=#4dd2dc ]]
  vim.cmd [[ hi! CursorLineNr guifg=#f0c674 ]]
  vim.cmd [[ hi! TelescopeBorder guifg=#ffff00 guibg=#ff0000 ]]
  vim.cmd [[ hi! WhichKeyGroup guifg=#4dd2dc ]]
  vim.cmd [[ hi! WhichKeyDesc guifg=#4dd2dc  ]]
end

local function EmptyRegisters()
  vim.api.nvim_exec([[
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
  ]], false)
end

local function OpenTerminal()
  vim.cmd("split term://zsh")
  vim.cmd("resize 10")
end

local function TurnOnGuides()
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.cursorline = true
  vim.wo.signcolumn = "yes"
  vim.wo.colorcolumn = "+1"
  vim.o.laststatus = 2
  vim.o.showtabline = 2
end

local function TurnOffGuides()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.cursorline = false
  vim.wo.signcolumn = "no"
  vim.wo.colorcolumn = ""
  vim.o.laststatus = 0
  vim.o.showtabline = 0
end

-----------------------------------------------------------------------------//
-- Mappings
-----------------------------------------------------------------------------//
-- Yank from cursor position to end-of-line
nnoremap('Y', 'y$')

-- Easier line-wise movement
-- nnoremap("gh", "g^")
-- nnoremap("gl", "g$")

-- Move selected line / block of text in visual mode
xnoremap('K', ":m '<-2<CR>gv=gv")
xnoremap('N', ":m '>+1<CR>gv=gv")

-- Alternate way to save
nnoremap("<c-s>", function()
  save_and_notify()
end)

-- Open url
nnoremap('gx', ":sil !xdg-open <c-r><c-a><cr>")

-- Better Navigation
nnoremap('<C-h>', '<C-w>h')
nnoremap('<C-n>', '<C-w>j')
nnoremap('<C-k>', '<C-w>k')
nnoremap('<C-l>', '<C-w>l')

-- Start new line from any cursor position
inoremap("<S-Return>", "<C-o>o")

if rvim.plugin.playground.active then
  nnoremap("<leader>aE", function()
    inspect_token()
  end)
end

-- Use alt + hjkl to resize windows
nnoremap('<M-n>', ':resize -2<CR>')
nnoremap('<M-k>', ':resize +2<CR>')
nnoremap('<M-h>', ':vertical resize +2<CR>')
nnoremap('<M-l>', ':vertical resize -2<CR>')

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

-- Alternate way to quit
nnoremap("<Leader>ax", ":wq!<CR>")
nnoremap("<Leader>az", ":q!<CR>")
nmap('W', 'q')
nnoremap('<Leader>x', ':q<CR>')
nnoremap('<C-z>', ':undo<CR>')
vnoremap('<C-z>', ':undo<CR>')
inoremap('<C-z>', ':undo<CR>')

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
nnoremap("<Leader>aO", ":<C-f>:resize 10<CR>") -- Close all folds

-- qflist
nnoremap("<Leader>vo", ":copen<CR>")

-- Terminal {{{
rvim.augroup("AddTerminalMappings", {
  {
    events = {"TermOpen"},
    targets = {"*:zsh"},
    command = function()
      if vim.bo.filetype == "" or vim.bo.filetype == "toggleterm" then
        local opts = {silent = false, buffer = 0}
        tnoremap("<esc>", [[<C-\><C-n>:bdelete!<CR>]], opts)
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
    end,
  },
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
nnoremap("<localleader>wv", "<C-W>t <C-W>H<C-W>=")
-- Change two vertically split windows to horizontal splits
nnoremap("<localleader>wh", "<C-W>t <C-W>K<C-W>=")
-- opens a vertical split
nnoremap("<Leader>av", "<C-W>vgf")
-- opens a horizontal split
nnoremap("<Leader>ah", "<C-W>s")
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
nnoremap("<leader>Iv", [[:vsplit $MYVIMRC<cr>]])

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
nnoremap("gf", function()
  open_file_or_create_new()
end)

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
nnoremap("gX", function()
  open_link()
end)

-- toggle_list
nnoremap("<leader>ls", function()
  toggle_list("c")
end)
nnoremap("<leader>li", function()
  toggle_list("l")
end)

-- Other remaps
nnoremap('<Leader>,', ':e ~/.config/nvim/lua/rvim/init.lua<CR>')
nnoremap('<Leader>.', ':e $MYVIMRC<CR>')
nnoremap('<leader><CR>', ':source $MYVIMRC<CR>')
nnoremap('<Leader>Ic', ':checkhealth<CR>')
nnoremap('<C-b>', ':QuickRun<CR>')
nnoremap('<Leader>Im', ':messages<CR>')
nnoremap('<Leader>vwm', function()
  ColorMyPencils()
end)
nnoremap('<leader>aR', function()
  EmptyRegisters()
end)
nnoremap('<Leader>;', function()
  OpenTerminal()
end)
nnoremap('<leader>ao', function()
  TurnOnGuides()
end)
nnoremap('<leader>ae', function()
  TurnOffGuides()
end)

-- Buffers
nnoremap('<Leader><Leader>', ':call v:lua.DelThisBuffer()<CR>')
nnoremap('<Leader>bdh', ':call v:lua.DelToLeft()<CR>')
nnoremap('<Leader>bda', ':call v:lua.DelAllBuffers()<CR>')
nnoremap('<Leader>bdx', ':call v:lua.DelAllExceptCurrent()<CR>')
vim.cmd [[vnoremap <Leader>rev :s/\%V.\+\%V./\=utils#RevStr(submatch(0))<CR>gv]]

-----------------------------------------------------------------------------//
-- Commands
-----------------------------------------------------------------------------//
-- https://github.com/CalinLeafshade/dots/blob/master/nvim/.config/nvim/lua/leafshade/rename.lua
function _G.__Rename(name)
  local curfilepath = vim.fn.expand("%:p:h")
  local newname = curfilepath .. "/" .. name
  vim.api.nvim_command(" saveas " .. newname)
end

rvim.command {"Todo", [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]]}

rvim.command {nargs = 1, "Rename", [[call v:lua.__Rename(<f-args>)]]}
