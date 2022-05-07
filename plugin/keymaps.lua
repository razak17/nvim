local utils = require("user.utils")

local nmap = rvim.nmap
local imap = rvim.imap
local nnoremap = rvim.nnoremap
local xnoremap = rvim.xnoremap
local vnoremap = rvim.vnoremap
local inoremap = rvim.inoremap
local cnoremap = rvim.cnoremap
local tnoremap = rvim.tnoremap
local onoremap = rvim.onoremap

local g = vim.g
g.mapleader = (rvim.keys.leader == "space" and " ") or rvim.keymaps.leader
g.maplocalleader = (rvim.keys.localleader == "space" and " ") or rvim.keymaps.localleader

------------------------------------------------------------------------------
-- Terminal {{{
-------------------------------------------------------------------------------
rvim.augroup("AddTerminalMappings", {
  {
    event = { "TermOpen" },
    pattern = { "term://*" },
    command = function()
      if vim.bo.filetype == "" or vim.bo.filetype == "toggleterm" then
        local opts = { silent = false, buffer = 0 }
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
    end,
  },
})
--}}}
------------------------------------------------------------------------------
-- MACROS {{{
------------------------------------------------------------------------------
-- Absolutely fantastic function from stoeffel/.dotfiles which allows you to
-- repeat macros across a visual range
------------------------------------------------------------------------------
-- TODO: converting this to lua does not work for some obscure reason.
vim.cmd([[
  function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
  endfunction
]])

xnoremap("@", ":<C-u>call ExecuteMacroOverVisualRange()<CR>", { silent = false })
--}}}
------------------------------------------------------------------------------
-- Arrows
------------------------------------------------------------------------------
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
cnoremap("<C-n>", "<Down>")
cnoremap("<C-p>", "<Up>")
-- <C-A> allows you to insert all matches on the command line e.g. bd *.js <c-a>
-- will insert all matching files e.g. :bd a.js b.js c.js
cnoremap("<c-x><c-a>", "<c-a>")
cnoremap("<C-a>", "<Home>")
cnoremap("<C-e>", "<End>")
cnoremap("<C-b>", "<Left>")
cnoremap("<C-d>", "<Del>")
cnoremap("<C-k>", [[<C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos() - 2]<CR>]])
-- move cursor one character backwards unless at the end of the command line
cnoremap("<C-f>", [[getcmdpos() > strlen(getcmdline())? &cedit: "\<Lt>Right>"]], { expr = true })
-- see :h cmdline-editing
cnoremap("<Esc>b", [[<S-Left>]])
cnoremap("<Esc>f", [[<S-Right>]])
-- Insert escaped '/' while inputting a search pattern
cnoremap("/", [[getcmdtype() == "/" ? "\/" : "/"]], { expr = true })
------------------------------------------------------------------------------
-- Save
------------------------------------------------------------------------------
-- Alternate way to save
nnoremap("<C-s>", ":silent! write<CR>")
-- Quit
nnoremap("<leader>x", "<cmd>lua require('user.utils').smart_quit()<CR>", "quit")
-- nnoremap("<leader>x", ":q!<cr>",  "quit" )
-- Write and quit all files, ZZ is NOT equivalent to this
nnoremap("qa", "<cmd>qa<CR>")
------------------------------------------------------------------------------
-- Quickfix
------------------------------------------------------------------------------
nnoremap("]q", "<cmd>cnext<CR>zz")
nnoremap("[q", "<cmd>cprev<CR>zz")
nnoremap("]l", "<cmd>lnext<cr>zz")
nnoremap("[l", "<cmd>lprev<cr>zz")
-------------------------------------------------------------------------------
-- ?ie | entire object
-------------------------------------------------------------------------------
xnoremap("ie", [[gg0oG$]])
onoremap("ie", [[<cmd>execute "normal! m`"<Bar>keepjumps normal! ggVG<CR>]])
-------------------------------------------------------------------------------
-- Core navigation
-------------------------------------------------------------------------------
-- Store relative line number jumps in the jumplist.
nnoremap("j", [[(v:count > 1 ? 'm`' . v:count : '') . 'gj']], { expr = true, silent = true })
nnoremap("k", [[(v:count > 1 ? 'm`' . v:count : '') . 'gk']], { expr = true, silent = true })
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap("0", "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true })
-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap("$", "g_")
-- jk is escape, THEN move to the right to preserve the cursor position, unless
-- at the first column.  <esc> will continue to work the default way.
-- NOTE: this is a recursive mapping so anything bound (by a plugin) to <esc> still works
imap("jk", [[col('.') == 1 ? '<esc>' : '<esc>l']], { expr = true })
-- Toggle top/center/bottom
nmap(
  "zz",
  [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']],
  { expr = true }
)
-- Move selected line / block of text in visual mode
xnoremap("K", ":m '<-2<CR>gv=gv")
xnoremap("J", ":m '>+1<CR>gv=gv")
------------------------------------------------------------------------------
-- Credit: JGunn Choi ?il | inner line
------------------------------------------------------------------------------
-- includes newline
xnoremap("al", "$o0")
onoremap("al", "<cmd>normal val<CR>")
--No Spaces or CR
xnoremap("il", [[<Esc>^vg_]])
onoremap("il", [[<cmd>normal! ^vg_<CR>]])
------------------------------------------------------------------------------
-- Add Empty space above and below
------------------------------------------------------------------------------
nnoremap("[<space>", [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]])
nnoremap("]<space>", [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]])
-- Paste in visual mode multiple times
xnoremap("p", "pgvy")
-- search visual selection
vnoremap("//", [[y/<C-R>"<CR>]])

-- Credit: Justinmk
nnoremap("g>", [[<cmd>set nomore<bar>40messages<bar>set more<CR>]])
-- Start new line from any cursor position
inoremap("<S-Return>", "<C-o>o")
------------------------------------------------------------------------------
-- Indent
------------------------------------------------------------------------------
vnoremap("<", "<gv")
vnoremap(">", ">gv")

------------------------------------------------------------------------------
-- Capitalize
------------------------------------------------------------------------------
nnoremap("<leader>U", "gUiw`]", "capitalize word")
inoremap("<C-u>", "<cmd>norm!gUiw`]a<CR>")

-- Help
nnoremap("<leader>H", ':h <C-R>=expand("<cword>")<cr><CR>', "help")

-- find visually selected text
vnoremap("*", [[y/<C-R>"<CR>]])

-- make . work with visually selected lines
vnoremap(".", ":norm.<CR>")

-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap("$", "g_")

-- Use alt + hjkl to resize windows
nnoremap("<M-j>", ":resize -2<CR>")
nnoremap("<M-k>", ":resize +2<CR>")
nnoremap("<M-l>", ":vertical resize -2<CR>")
nnoremap("<M-h>", ":vertical resize +2<CR>")

-- Yank from cursor position to end-of-line
nnoremap("Y", "y$")

-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap("0", "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true })

-- Add Empty space above and below
nnoremap("[<space>", [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]])
nnoremap("]<space>", [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]])

-- Open url
-- nnoremap["gx"] = ":sil !xdg-open <c-r><c-a><cr>"

-- replicate netrw functionality
nnoremap("gx", function()
  utils.open_link()
end)

------------------------------------------------------------------------------
-- Utils
------------------------------------------------------------------------------
nnoremap("<leader>LV", function()
  utils.color_my_pencils()
end, "vim with me")

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
nnoremap("<leader>B", '/<C-R>=escape(expand("<cword>"), "/")<CR><CR>', "find cword")

-- Greatest remap ever
vnoremap("<leader>p", '"_dP', "greatest remap")

-- Reverse Line
vnoremap("<leader>r", [[:s/\%V.\+\%V./\=utils#rev_str(submatch(0))<CR>gv]], "reverse line")
----------------------------------------------------------------------------------
-- Windows
----------------------------------------------------------------------------------
nnoremap(
  "<localleader>wv",
  "<C-W>t <C-W>H<C-W>=",
  "change two vertically split windows to horizontal splits"
)
-- Change two vertically split windows to horizontal splits
nnoremap(
  "<localleader>wh",
  "<C-W>t <C-W>K<C-W>=",
  "change two horizontally split windows to vertical splits"
)

----------------------------------------------------------------------------------
-- Folds
----------------------------------------------------------------------------------
nnoremap("<leader>FR", "zA") -- Recursively toggle
nnoremap("<leader>Fl", "za") -- Toggle fold under the cursor
nnoremap("<leader>Fo", "zR") -- Open all folds
nnoremap("<leader>Fx", "zM") -- Close all folds
nnoremap("<leader>Fz", [[zMzvzz]]) -- Refocus folds

-- Make zO recursively open whatever top level fold we're in, no matter where the
-- cursor happens to be.
nnoremap("zO", [[zCzO]])

------------------------------------------------------------------------------
-- Delimiters
------------------------------------------------------------------------------
-- Conditionally modify character at end of line
nnoremap("<localleader>,", utils.modify_line_end_delimiter(","), "append comma")
nnoremap("<localleader>;", utils.modify_line_end_delimiter(";"), "append semi colon")
nnoremap("<localleader>.", utils.modify_line_end_delimiter("."), "append period")

-----------------------------------------------------------------------------//
-- Quick find/replace
-----------------------------------------------------------------------------//
nnoremap("<leader>[", [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], "replace all")
nnoremap("<leader>]", [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], "replace in line")
vnoremap("<leader>[", [["zy:%s/<C-r><C-o>"/]], "replace all")
-----------------------------------------------------------------------------//
-- open a new file in the same directory
nnoremap("<leader>no", [[:e <C-R>=expand("%:p:h") . "/" <CR>]], "open file in same dir")
-- create a new file in the same directory
nnoremap("<leader>nf", [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]], "create new file in same dir")
------------------------------------------------------------------------------
-- Quotes
------------------------------------------------------------------------------
nnoremap([[<leader>"]], [[ciw"<c-r>""<esc>]], "wrap double quotes")
nnoremap("<leader>`", [[ciw`<c-r>"`<esc>]], "wrap backticks")
nnoremap("<leader>'", [[ciw'<c-r>"'<esc>]], "wrap single quotes")
nnoremap("<leader>)", [[ciw(<c-r>")<esc>]], "wrap parenthesis")
nnoremap("<leader>}", [[ciw{<c-r>"}<esc>]], "wrap curly bracket")

-- Map Q to replay q register
nnoremap("Q", "@q")

------------------------------------------------------------------------------
-- Multiple Cursor Replacement
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
------------------------------------------------------------------------------
nnoremap("cn", "*``cgn")
nnoremap("cN", "*``cgN")

-- 1. Position the cursor over a word; alternatively, make a selection.
-- 2. Hit cq to start recording the macro.
-- 3. Once you are done with the macro, go back to normal mode.
-- 4. Hit Enter to repeat the macro over search matches.
function rvim.mappings.setup_CR()
  nmap("<Enter>", [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]])
end

vim.g.mc = rvim.replace_termcodes([[y/\V<C-r>=escape(@", '/')<CR><CR>]])
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

------------------------------------------------------------------------------
-- Command mode related
------------------------------------------------------------------------------
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

-- Search DuckDuckGo
nnoremap(
  "<leader>?",
  [[:lua rvim.mappings.google(vim.fn.expand("<cword>"), false)<cr>]],
  "search word"
)
xnoremap(
  "<leader>?",
  [["gy:lua rvim.mappings.google(vim.api.nvim_eval("@g"), false)<cr>gv]],
  "search selection"
)

-- Search Github
nnoremap(
  "<leader>L?",
  [[:lua rvim.mappings.google(vim.fn.expand("<cword>"), true)<cr>]],
  "github search word"
)
xnoremap(
  "<leader>L?",
  [["gy:lua rvim.mappings.google(vim.api.nvim_eval("@g"), true)<cr>gv]],
  "github search selection"
)

-- Buffers - Del All Others
nnoremap("<leader>bc", function()
  vim.api.nvim_exec(
    [[
      wall
      silent execute 'bdelete ' . join(utils#buf_filt(1))
    ]],
    false
  )
end, "close all others")
------------------------------------------------------------------------------
-- Personal
------------------------------------------------------------------------------
-- leave extra space when deleting word
nnoremap("dw", "cw<ESC>")
-- Next greatest remap ever : asbjornHaland
nnoremap("<leader>y", '"+y', "yank")
vnoremap("<leader>y", '"+y', "yank")
-- Whole file delete yank, paste
nnoremap("<leader>aa", 'gg"+VG', "select all")
-- nnoremap("<leader>D", 'gg"+VGd', "delete all")
nnoremap("<leader>Y", 'gg"+yG', "yank all")
-- actions
nnoremap("<leader>=", "<C-W>=", "balance window")
-- opens a horizontal split
nnoremap("<leader>ah", "<C-W>s", "horizontal split")
-- opens a vertical split
nnoremap("<leader>V", "<C-W>v", "vsplit")
-- Bufferlline
-- if not rvim.plugins.ui.bufferline.active then
--   nnoremap("<S-l>", ":bnext<CR>")
--   nnoremap("<S-h>", ":bprevious<CR>")
-- end

nnoremap("<leader>lG", function()
  require("user.lsp.templates").generate_templates()
  vim.notify("Templates have been generated", nil, { title = "Lsp" })
end, "lsp: generate templates")

nnoremap("<leader>lD", function()
  require("user.lsp.templates").remove_template_files()
  vim.notify("Templates have been removed", nil, { title = "Lsp" })
end, "lsp: delete templates")
------------------------------------------------------------------------------
-- Undo
------------------------------------------------------------------------------
nnoremap("<C-z>", ":undo<CR>")
vnoremap("<C-z>", ":undo<CR><Esc>")
xnoremap("<C-z>", ":undo<CR><Esc>")
inoremap("<c-z>", [[<Esc>:undo<CR>]])
------------------------------------------------------------------------------
-- Escape
------------------------------------------------------------------------------
nnoremap("<C-c>", "<Esc>")
------------------------------------------------------------------------------
-- Window Movement
------------------------------------------------------------------------------
nnoremap("<C-h>", "<C-w>h")
nnoremap("<C-j>", "<C-w>j")
nnoremap("<C-k>", "<C-w>k")
nnoremap("<C-l>", "<C-w>l")
------------------------------------------------------------------------------
-- Line Movement
------------------------------------------------------------------------------
nnoremap("<A-j>", ":m .+1<CR>==")
nnoremap("<A-k>", ":m .-2<CR>==")
