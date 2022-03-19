local utils = require "user.utils"

local nmap = rvim.nmap
local nnoremap = rvim.nnoremap
local xnoremap = rvim.xnoremap
local vnoremap = rvim.vnoremap
local inoremap = rvim.inoremap
local cnoremap = rvim.cnoremap
local tnoremap = rvim.tnoremap

local g = vim.g
g.mapleader = (rvim.leader == "space" and " ") or rvim.leader
g.maplocalleader = (rvim.localleader == "space" and " ") or rvim.localleader

-----------------------------------------------------------------------------//
-- keymaps
-----------------------------------------------------------------------------//

-- Undo
nnoremap("<C-z>", ":undo<CR>")
vnoremap("<C-z>", ":undo<CR><Esc>")
xnoremap("<C-z>", ":undo<CR><Esc>")
inoremap("<c-z>", [[<Esc>:undo<CR>]])

-- remap esc to use cc
nnoremap("<C-c>", "<Esc>")

-- Better window movement
nnoremap("<C-h>", "<C-w>h")
nnoremap("<C-j>", "<C-w>j")
nnoremap("<C-k>", "<C-w>k")
nnoremap("<C-l>", "<C-w>l")

-- Move current line / block with Alt-j/k a la vscode.
nnoremap("<A-j>", ":m .+1<CR>==")
nnoremap("<A-k>", ":m .-2<CR>==")

-- Disable arrows in normal mode
nnoremap("<down>", "<nop>")
nnoremap("<up>", "<nop>")
nnoremap("<left>", "<nop>")
nnoremap("<right>", "<nop>")

-- Move selected line / block of text in visual mode
xnoremap("K", ":m '<-2<CR>gv=gv")
xnoremap("J", ":m '>+1<CR>gv=gv")

-- Add Empty space above and below
nnoremap("[<space>", [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]])
nnoremap("]<space>", [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]])

-- Paste in visual mode multiple times
xnoremap("p", "pgvy")

-- leave extra space when deleting word
nnoremap("dw", "cw<ESC>")

-- Repeat last substitute with flags
xnoremap("&", "<cmd>&&<CR>")

-- Start new line from any cursor position
inoremap("<S-Return>", "<C-o>o")

-- Better indenting
vnoremap("<", "<gv")
vnoremap(">", ">gv")

-- search visual selection
vnoremap("//", [[y/<C-R>"<CR>]])

-- Capitalize
nnoremap("<leader>U", "gUiw`]", { label = "capitalize word" })
inoremap("C-u>", "<cmd>norm!gUiw`]a<CR>")

-- Help
nnoremap("<leader>H", ':h <C-R>=expand("<cword>")<cr><CR>', { label = "help" })

-- Credit: Justinmk
nnoremap("g>", [[<cmd>set nomore<bar>40messages<bar>set more<CR>]])

-- find visually selected text
vnoremap("*", [[y/<C-R>"<CR>]])

-- make . work with visually selected lines
vnoremap(".", ":norm.<CR>")

-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap("$", "g_")

tnoremap("<esc>", "<C-\\><C-n>:q!<CR>")
tnoremap("jk", "<C-\\><C-n>")
tnoremap("<C-h>", "<C\\><C-n><C-W>h")
tnoremap("<C-j>", "<C-\\><C-n><C-W>j")
tnoremap("<C-k>", "<C-\\><C-n><C-W>k")
tnoremap("<C-l>", "<C-\\><C-n><C-W>l")
tnoremap("]t", "C-\\><C-n>:tablast<CR>")
tnoremap("[t", "C-\\><C-n>:tabnext<CR>")
tnoremap("S-Tab>", "C-\\><C-n>:bprev<CR>")

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
cnoremap(
  "<Tab>",
  [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>/<C-r>/" : "<C-z>"]],
  { expr = true }
)

cnoremap(
  "<S-Tab>",
  [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>?<C-r>/" : "<S-Tab>"]],
  { expr = true }
)

-- Use alt + hjkl to resize windows
nnoremap("<M-j>", ":resize -2<CR>")
nnoremap("<M-k>", ":resize +2<CR>")
nnoremap("<M-l>", ":vertical resize -2<CR>")
nnoremap("<M-h>", ":vertical resize +2<CR>")

-- Yank from cursor position to end-of-line
nnoremap("Y", "y$")

-- Repeat last substitute with flags
nnoremap("&", "<cmd>&&<CR>")

-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap("0", "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true })

-- Map Q to replay q register
nnoremap("Q", "@q")

-----------------------------------------------------------------------------//
-- Multiple Cursor Replacement
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
-----------------------------------------------------------------------------//
nnoremap("cn", "*``cgn")
nnoremap("cN", "*``cgN")

-- 1. Position the cursor over a word; alternatively, make a selection.
-- 2. Hit cq to start recording the macro.
-- 3. Once you are done with the macro, go back to normal mode.
-- 4. Hit Enter to repeat the macro over search matches.
function rvim.mappings.setup_CR()
  nmap("<Enter>", [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]])
end

vim.g.mc = rvim.replace_termcodes [[y/\V<C-r>=escape(@", '/')<CR><CR>]]
xnoremap("cn", [[g:mc . "``cgn"]], { expr = true, silent = true })
xnoremap("cN", [[g:mc . "``cgN"]], { expr = true, silent = true })
nnoremap("cq", [[:\<C-u>call v:lua.rvim.mappings.setup_CR()<CR>*``qz]])
nnoremap("cQ", [[:\<C-u>call v:lua.rvim.mappings.setup_CR()<CR>#``qz]])
xnoremap(
  "cq",
  [[":\<C-u>call v:lua.rvim.mappings.setup_CR()<CR>gv" . g:mc . "``qz"]],
  { expr = true }
)
xnoremap(
  "cQ",
  [[":\<C-u>call v:lua.rvim.mappings.setup_CR()<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
  { expr = true }
)

-- Add Empty space above and below
nnoremap("[<space>", [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]])
nnoremap("]<space>", [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]])

-- Smart mappings on the command line
-- cnoremap("w!!", [[w !sudo tee % >/dev/null]])

-- insert path of current file into a command
cnoremap("%%", "<C-r>=fnameescape(expand('%'))<cr>")
cnoremap("::", "<C-r>=fnameescape(expand('%:p:h'))<cr>/")

------------------------------------------------------------------------------
-- Credit: June Gunn <leader>?/! | Google it / Feeling lucky
------------------------------------------------------------------------------
local fn = vim.fn
function rvim.mappings.google(pat, gh)
  local query = '"' .. fn.substitute(pat, '["\n]', " ", "g") .. '"'
  query = fn.substitute(query, "[[:punct:] ]", [[\=printf("%%%02X", char2nr(submatch(0)))]], "g")
  if gh then
    fn.system(fn.printf(rvim.open_command .. ' "https://github.com/search?%sq=%s"', "", query))
  else
    fn.system(
      fn.printf(rvim.open_command .. ' "https://html.duckduckgo.com/html?%sq=%s"', "", query)
    )
  end
end

-- Searcg DuckDuckGo
nnoremap(
  "<leader>?",
  [[:lua rvim.mappings.google(vim.fn.expand("<cword>"), false)<cr>]],
  { label = "search word" }
)
xnoremap(
  "<leader>?",
  [["gy:lua rvim.mappings.google(vim.api.nvim_eval("@g"), false)<cr>gv]],
  { label = "search selection" }
)

-- Search Github
nnoremap(
  "<leader>L?",
  [[:lua rvim.mappings.google(vim.fn.expand("<cword>"), true)<cr>]],
  { label = "github search word" }
)
xnoremap(
  "<leader>L?",
  [["gy:lua rvim.mappings.google(vim.api.nvim_eval("@g"), true)<cr>gv]],
  { label = "github search selection" }
)

-- QuickRun
nnoremap("<C-b>", ":QuickRun<CR>")

-- Quit
nnoremap("<leader>x", ":q!<cr>", { label = "quit" })

-- Alternate way to save
nnoremap("<C-s>", ":silent! write<CR>")

nnoremap("gf", "<cmd>e <cfile><CR>")

-- Open url
-- nnoremap["gx"] = ":sil !xdg-open <c-r><c-a><cr>"

-- replicate netrw functionality
nnoremap("gx", function()
  utils.open_link()
end)

-----------------------------------------------------------------------------//
-- leader keymap
-----------------------------------------------------------------------------//

nnoremap("<leader>LV", function()
  utils.color_my_pencils()
end, { label = "vim with me" })

nnoremap("<leader>aR", function()
  utils.empty_registers()
end)

nnoremap("<leader>a;", function()
  utils.open_terminal()
end)

nnoremap("<leader>ao", function()
  utils.turn_on_guides()
end)

nnoremap("<leader>ae", function()
  utils.turn_off_guides()
end)

-- Search Files
nnoremap("<leader>B", '/<C-R>=escape(expand("<cword>"), "/")<CR><CR>', { label = "find cword" })

-- Greatest remap ever
vnoremap("<leader>p", '"_dP', { label = "greatest remap" })

-- Reverse Line
vnoremap(
  "<leader>r",
  [[:s/\%V.\+\%V./\=utils#rev_str(submatch(0))<CR>gv]],
  { label = "reverse line" }
)

-- Next greatest remap ever : asbjornHaland
nnoremap("<leader>y", '"+y', { label = "yank" })
vnoremap("<leader>y", '"+y', { label = "yank" })

-- Whole file delete yank, paste
nnoremap("<leader>A", 'gg"+VG', { label = "select all" })
-- nnoremap("<leader>D", 'gg"+VGd', {label="delete all"})
nnoremap("<leader>Y", 'gg"+yG', { label = "yank all" })

-- actions
nnoremap("<leader>=", "<C-W>=", { label = "balance window" })
-- opens a horizontal split
nnoremap("<leader>ah", "<C-W>s", { label = "horizontal split" })
-- opens a vertical split
nnoremap("<leader>V", "<C-W>v", { label = "vertical split" })
-- Change two horizontally split windows to vertical splits
nnoremap(
  "<localleader>wv",
  "<C-W>t <C-W>H<C-W>=",
  { label = "change two vertically split windows to horizontal splits" }
)
-- Change two vertically split windows to horizontal splits
nnoremap(
  "<localleader>wh",
  "<C-W>t <C-W>K<C-W>=",
  { label = "change two horizontally split windows to vertical splits" }
)

-- Folds
nnoremap("<leader>FR", "zA") -- Recursively toggle
nnoremap("<leader>Fl", "za") -- Toggle fold under the cursor
nnoremap("<leader>Fo", "zR") -- Open all folds
nnoremap("<leader>Fx", "zM") -- Close all folds
nnoremap("<leader>Fz", [[zMzvzz]]) -- Refocus folds

-- Make zO recursively open whatever top level fold we're in, no matter where the
-- cursor happens to be.
nnoremap("FO", [[zCzO]])

-- Conditionally modify character at end of line
nnoremap(
  "<localleader>,",
  "<cmd>call utils#modify_line_end_delimiter(',')<cr>",
  { label = "append comma" }
)
nnoremap(
  "<localleader>;",
  "<cmd>call utils#modify_line_end_delimiter(';')<cr>",
  { label = "append semi colon" }
)
nnoremap(
  "<localleader>.",
  "<cmd>call utils#modify_line_end_delimiter('.')<cr>",
  { label = "append period" }
)

-- Quick find/replace
nnoremap(
  "<leader>[",
  [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]],
  { silent = false, label = "replace all" }
)
nnoremap(
  "<leader>]",
  [[:s/\<<C-r>=expand("<cword>")<CR>\>/]],
  { silent = false, label = "replace in line" }
)
vnoremap("<leader>[", [["zy:%s/<C-r><C-o>"/]], { silent = false, label = "replace all" })

-- open a new file in the same directory
nnoremap(
  "<leader>nf",
  [[:e <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false, label = "open file in same dir" }
)
-- create a new file in the same directory
nnoremap(
  "<leader>ns",
  [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false, label = "create new file in same dir" }
)

-- Wrap
nnoremap('<leader>"', [[ciw"<c-r>""<esc>]], { label = "wrap double quotes" })
nnoremap("<leader>`", [[ciw`<c-r>"`<esc>]], { label = "wrap backticks" })
nnoremap("<leader>'", [[ciw'<c-r>"'<esc>]], { label = "wrap single quotes" })
nnoremap("<leader>)", [[ciw(<c-r>")<esc>]], { label = "wrap parenthesis" })
nnoremap("<leader>}", [[ciw{<c-r>"}<esc>]], { label = "wrap curly bracket" })

-- Buffers - Del All Others
nnoremap("<leader>bc", function()
  vim.api.nvim_exec(
    [[
      wall
      silent execute 'bdelete ' . join(utils#buf_filt(1))
    ]],
    false
  )
end, {
  label = "close all others",
})

-- Bufferlline
if not rvim.plugins.ui.bufferline.active then
  nnoremap("<S-l>", ":bnext<CR>")
  nnoremap("<S-h>", ":bprevious<CR>")
end

nnoremap("<leader>lG", function()
  require("user.lsp.templates").generate_templates()
end, {
  label = "lsp: generate templates",
})

nnoremap("<leader>lD", function()
  require("user.lsp.templates").remove_template_files()
end, {
  label = "lsp: delete templates",
})
