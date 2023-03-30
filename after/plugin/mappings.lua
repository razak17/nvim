if not rvim then return end

local fn, api, fmt = vim.fn, vim.api, string.format

local recursive_map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.remap = true
  map(mode, lhs, rhs, opts)
end

local nmap = function(...) recursive_map('n', ...) end
local imap = function(...) recursive_map('i', ...) end
local nnoremap = function(...) map('n', ...) end
local xnoremap = function(...) map('x', ...) end
local vnoremap = function(...) map('v', ...) end
local inoremap = function(...) map('i', ...) end
local onoremap = function(...) map('o', ...) end
local cnoremap = function(...) map('c', ...) end

----------------------------------------------------------------------------------------------------
-- MACROS {{{
----------------------------------------------------------------------------------------------------
-- repeat macros across a visual range
vim.cmd([[
  function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
  endfunction
]])
xnoremap('@', ':<C-u>call ExecuteMacroOverVisualRange()<CR>', { silent = false })
----------------------------------------------------------------------------------------------------
-- Credit: JGunn Choi ?il | inner line
----------------------------------------------------------------------------------------------------
-- includes newline
xnoremap('al', '$o0')
onoremap('al', '<cmd>normal val<CR>')
-- No Spaces or CR
xnoremap('il', [[<Esc>^vg_]])
onoremap('il', [[<cmd>normal! ^vg_<CR>]])
-----------------------------------------------------------------------------//
-- Paste in visual mode multiple times
xnoremap('p', 'pgvy')
-- search visual selection
vnoremap('//', [[y/<C-R>"<CR>]])
-- show message history
nnoremap('g>', [[<cmd>set nomore<bar>40messages<bar>set more<CR>]])
-- Enter key should repeat the last macro recorded or just act as enter
nnoremap('<leader><CR>', [[empty(&buftype) ? '@@':'<CR>']], { expr = true, desc = 'repeat macro' })
-- Evaluates whether there is a fold on the current line if so unfold it else return a normal space
nnoremap('<space><space>', [[@=(foldlevel('.')?'za':"\<Space>")<CR>]], { desc = 'toggle fold' })
-- Make zO recursively open whatever top level fold we're in, no matter where the
-- cursor happens to be.
nnoremap('zO', [[zCzO]])
----------------------------------------------------------------------------------------------------
-- Delimiters
----------------------------------------------------------------------------------------------------
-- TLDR: Conditionally modify character at end of line (add, remove or modify)
---@param character string
---@return function
local function modify_line_end_delimiter(character)
  local delimiters = { ',', ';' }
  return function()
    local line = api.nvim_get_current_line()
    local last_char = line:sub(-1)
    if last_char == character then
      api.nvim_set_current_line(line:sub(1, #line - 1))
      return
    end
    if vim.tbl_contains(delimiters, last_char) then
      api.nvim_set_current_line(line:sub(1, #line - 1) .. character)
      return
    end
    api.nvim_set_current_line(line .. character)
  end
end

nnoremap('<localleader>,', modify_line_end_delimiter(','), { desc = 'append comma' })
nnoremap('<localleader>;', modify_line_end_delimiter(';'), { desc = 'append semi colon' })
----------------------------------------------------------------------------------------------------
nnoremap('<leader>I', '<cmd>Inspect<CR>', { desc = 'inspect' })
----------------------------------------------------------------------------------------------------
-- Capitalize
nnoremap('<leader>U', 'gUiw`]', { desc = 'capitalize word' })
----------------------------------------------------------------------------------------------------
-- Moving lines/visual block
xnoremap('K', ":m '<-2<CR>gv=gv")
xnoremap('J', ":m '>+1<CR>gv=gv")
----------------------------------------------------------------------------------------------------
-- Windows
----------------------------------------------------------------------------------------------------
-- change two vertically split windows to horizontal splits
nnoremap('<localleader>wv', '<C-W>t <C-W>H<C-W>=')
-- change two horizontally split windows to vertical splits
nnoremap('<localleader>wh', '<C-W>t <C-W>K<C-W>=', { desc = '' })
-- make . work with visually selected lines
vnoremap('.', ':norm.<CR>')
-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap('$', 'g_')
-- Maintain cursor position when joining lines
nnoremap('J', 'mzJ`z')
-- Keep search terms in the middle
nnoremap('n', 'nzzzv')
nnoremap('N', 'Nzzzv')
-- Window Movement
nnoremap('<C-h>', '<C-w>h')
nnoremap('<C-j>', '<C-w>j')
nnoremap('<C-k>', '<C-w>k')
nnoremap('<C-l>', '<C-w>l')
-- Buffer Movement
nnoremap('H', '<cmd>bprevious<CR>', { desc = 'previous buffer' })
nnoremap('L', '<cmd>bnext<CR>', { desc = 'next buffer' })
-- Greatest remap ever
vnoremap('<leader>p', '"_dP', { desc = 'greatest remap' })
-- Next greatest remap ever : asbjornHaland
nnoremap('<leader>y', '"+y', { desc = 'yank' })
vnoremap('<leader>y', '"+y', { desc = 'yank' })
nnoremap('<leader>dd', '"_d', { desc = 'delete' })
vnoremap('<leader>dd', '"_d', { desc = 'delete' })
----------------------------------------------------------------------------------------------------
-- Yank / Select / Delete All
nnoremap('<leader>Y', 'gg"+VGy<C-o>', { desc = 'yank all' })
nnoremap('<leader>A', 'gg"+VG', { desc = 'select all' })
nnoremap('<leader>D', 'gg"+VGd', { desc = 'delete all' })
----------------------------------------------------------------------------------------------------
-- Quick find/replace
nnoremap('<leader>[', [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], { desc = 'replace all' })
nnoremap('<leader>]', [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], { desc = 'replace in line' })
vnoremap('<leader>[', [["zy:%s/<C-r><C-o>"/]], { desc = 'replace all' })
-- Visual shifting (does not exit Visual mode)
vnoremap('<', '<gv')
vnoremap('>', '>gv')
----------------------------------------------------------------------------------------------------
-- open a new file in the same directory
nnoremap('<leader>no', [[:e <C-R>=expand("%:p:h") . "/" <CR>]], { desc = 'open file' })
-- create a new file in the same directory
nnoremap('<leader>nf', [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]], { desc = 'create new file' })
----------------------------------------------------------------------------------------------------
-- Arrows
nnoremap('<down>', '<nop>')
nnoremap('<up>', '<nop>')
nnoremap('<left>', '<nop>')
nnoremap('<right>', '<nop>')
inoremap('<up>', '<nop>')
inoremap('<down>', '<nop>')
inoremap('<left>', '<nop>')
inoremap('<right>', '<nop>')
----------------------------------------------------------------------------------------------------
-- Commandline mappings
----------------------------------------------------------------------------------------------------
-- https://github.com/tpope/vim-rsi/blob/master/plugin/rsi.vim
-- c-a / c-e everywhere - RSI.vim provides these
cnoremap('<C-n>', '<Down>')
cnoremap('<C-p>', '<Up>')
-- <C-A> allows you to insert all matches on the command line e.g. bd *.js <c-a>
-- will insert all matching files e.g. :bd a.js b.js c.js
cnoremap('<c-x><c-a>', '<c-a>')
-- move cursor one character backwards unless at the end of the command line
cnoremap('<C-f>', function()
  if fn.getcmdpos() == fn.strlen(fn.getcmdline()) then return '<c-f>' end
  return '<Right>'
end, { expr = true })
cnoremap('<C-b>', '<Left>')
cnoremap('<C-d>', '<Del>')

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
local function search(direction_key, default)
  local cmd = fn.getcmdtype()
  return (cmd == '/' or cmd == '?') and fmt('<CR>%s<C-r>/', direction_key) or default
end
cnoremap('<Tab>', function() return search('/', '<Tab>') end, { expr = true })
cnoremap('<S-Tab>', function() return search('?', '<S-Tab>') end, { expr = true })
-- insert path of current file into a command
cnoremap('%%', "<C-r>=fnameescape(expand('%'))<cr>")
cnoremap('::', "<C-r>=fnameescape(expand('%:p:h'))<cr>/")
-- NOTE: this uses write specifically because we need to trigger a filesystem event
-- even if the file isn't changed so that things like hot reload work
nnoremap('<C-s>', '<cmd>silent! write<CR>')
nnoremap('<leader>x', ':q<CR>', { desc = 'quit' })
nnoremap('<leader>q', ':q<CR>', { desc = 'quit' })
----------------------------------------------------------------------------------------------------
-- ?ie | entire object
----------------------------------------------------------------------------------------------------
xnoremap('ie', [[gg0oG$]])
onoremap('ie', [[<cmd>execute "normal! m`"<Bar>keepjumps normal! ggVG<CR>]])
----------------------------------------------------------------------------------------------------
-- Core navigation
----------------------------------------------------------------------------------------------------
-- Store relative line number jumps in the jumplist.
nnoremap('j', [[(v:count > 1 ? 'm`' . v:count : '') . 'gj']], { expr = true, silent = true })
nnoremap('k', [[(v:count > 1 ? 'm`' . v:count : '') . 'gk']], { expr = true, silent = true })
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap('0', "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true })
-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap('$', 'g_')
-- jk is escape, THEN move to the right to preserve the cursor position, unless
-- at the first column.  <esc> will continue to work the default way.
-- NOTE: this is a recursive mapping so anything bound (by a plugin) to <esc> still works
imap('jk', [[col('.') == 1 ? '<esc>' : '<esc>l']], { expr = true })
-- Toggle top/center/bottom
nmap('zz', [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']], { expr = true })
-- Escape
nnoremap('<C-c>', '<Esc>')

----------------------------------------------------------------------------------------------------
-- Web Search
----------------------------------------------------------------------------------------------------
function rvim.mappings.ddg(path) rvim.web_search(path, 'https://html.duckduckgo.com/html?q=') end
function rvim.mappings.gh(path) rvim.web_search(path, 'https://github.com/search?q=') end

-- Search DuckDuckGo
nnoremap('<localleader>?', [[:lua rvim.mappings.ddg(vim.fn.expand("<cword>"))<CR>]], { desc = 'search word' })
xnoremap('<localleader>?', [["gy:lua rvim.mappings.ddg(vim.api.nvim_eval("@g"))<CR>gv]], { desc = 'search word' })
-- Search Github
nnoremap('<localleader>!', [[:lua rvim.mappings.gh(vim.fn.expand("<cword>"))<CR>]], { desc = 'gh search word' })
xnoremap('<localleader>!', [["gy:lua rvim.mappings.gh(vim.api.nvim_eval("@g"))<CR>gv]], { desc = 'gh search word' })
-----------------------------------------------------------------------------//
-- GX - replicate netrw functionality
-----------------------------------------------------------------------------//
nnoremap('gx', function()
  local file = fn.expand('<cfile>')
  if not file or fn.isdirectory(file) > 0 then return vim.cmd.edit(file) end
  if file:match('http[s]?://') then return rvim.open(file) end

  -- consider anything that looks like string/string a github link
  local plugin_url_regex = '[%a%d%-%.%_]*%/[%a%d%-%.%_]*'
  local link = string.match(file, plugin_url_regex)
  print(link)
  if link then return rvim.open(fmt('https://www.github.com/%s', link)) end
end)
-----------------------------------------------------------------------------//
nnoremap('<leader>lq', rvim.list.qf.toggle, { desc = 'toggle quickfix list' })
nnoremap('<leader>ll', rvim.list.loc.toggle, { desc = 'toggle location list' })

-----------------------------------------------------------------------------//
-- Completion
-----------------------------------------------------------------------------//
-- cycle the completion menu with <TAB>
inoremap('<tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
inoremap('<s-tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
----------------------------------------------------------------------------------------------------
-- Help
nnoremap('<leader>ah', ':h <C-R>=expand("<cword>")<CR><CR>', { desc = 'help' })
----------------------------------------------------------------------------------------------------
-- Undo
nnoremap('<C-z>', '<cmd>undo<CR>')
vnoremap('<C-z>', '<cmd>undo<CR><Esc>')
xnoremap('<C-z>', '<cmd>undo<CR><Esc>')
inoremap('<c-z>', [[<Esc>:undo<CR>]])
----------------------------------------------------------------------------------------------------
-- Reverse Line
function rvim.rev_str(str) return string.reverse(str) end
vnoremap('<leader>R', [[:s/\%V.\+\%V./\=v:lua.rvim.rev_str(submatch(0))<CR>gv<ESC>]], { desc = 'reverse line' })
----------------------------------------------------------------------------------------------------
-- Inspect treesitter tree
nnoremap(
  '<localleader>le',
  function() vim.treesitter.inspect_tree({ command = 'botright 60vnew' }) end,
  { desc = 'open ts tree for current buffer' }
)
----------------------------------------------------------------------------------------------------
-- UI Toggles
----------------------------------------------------------------------------------------------------
local function bool2str(bool) return bool and 'on' or 'off' end
local function ui_notify(msg, type)
  vim.schedule(function() vim.notify(msg, type, { title = 'UI Toggles' }) end)
end
---@param opt string
local function toggle_opt(opt)
  local prev = api.nvim_get_option_value(opt, {})
  local value
  if type(prev) == 'boolean' then value = not prev end
  vim.wo[opt] = value
  -- vim.notify(fmt('%s set to %s', opt, tostring(value)), 'info', { title = 'UI Toggles' })
  ui_notify(string.format('%s %s', opt, bool2str(vim.wo[opt])))
end
nnoremap('<leader>ow', function() toggle_opt('wrap') end, { desc = 'toggle wrap' })
nnoremap('<leader>oL', function() toggle_opt('cursorline') end, { desc = 'toggle cursorline' })
nnoremap('<leader>os', function() toggle_opt('spell') end, { desc = 'toggle spell' })

--- Toggle laststatus=3|2|0
local function toggle_statusline()
  local laststatus = vim.opt.laststatus:get()
  local status
  if laststatus == 0 then
    vim.opt.laststatus = 2
    status = 'local'
  elseif laststatus == 2 then
    vim.opt.laststatus = 3
    status = 'global'
  elseif laststatus == 3 then
    vim.opt.laststatus = 0
    status = 'off'
  end
  ui_notify(string.format('statusline %s', status))
end
nnoremap('<leader>ol', toggle_statusline, { desc = 'toggle statusline' })

--- Toggle conceal=2|0
local function toggle_conceal()
  vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0
  ui_notify(string.format('conceal %s', bool2str(vim.opt.conceallevel:get() == 2)))
end
--- Toggle conceal cursor=n|''
local function toggle_conceal_cursor()
  vim.opt.concealcursor = vim.opt.concealcursor:get() == 'n' and '' or 'n'
  ui_notify(string.format('conceal cursor %s', bool2str(vim.opt.concealcursor:get() == '')))
end
nnoremap('<localleader>cl', toggle_conceal, { desc = 'toggle conceallevel' })
nnoremap('<localleader>cc', toggle_conceal_cursor, { desc = 'toggle concealcursor' })
----------------------------------------------------------------------------------------------------
-- Abbreviations
vim.cmd([[
  inoreabbrev fucntion function
  inoreabbrev cosnt const
  cnoreabbrev W! w!
  cnoreabbrev Q! q!
  cnoreabbrev Wq wq
  cnoreabbrev wQ wq
  cnoreabbrev WQ wq
  cnoreabbrev W w
  cnoreabbrev Q q
]])
