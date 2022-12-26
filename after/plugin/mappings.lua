if not rvim then return end

local fn = vim.fn
local api = vim.api
local fmt = string.format

local imap = rvim.imap
local nmap = rvim.nmap
local nnoremap = rvim.nnoremap
local xnoremap = rvim.xnoremap
local vnoremap = rvim.vnoremap
local inoremap = rvim.inoremap
local cnoremap = rvim.cnoremap
local tnoremap = rvim.tnoremap
local onoremap = rvim.onoremap

----------------------------------------------------------------------------------------------------
-- Terminal {{{
----------------------------------------------------------------------------------------------------
rvim.augroup('AddTerminalMappings', {
  {
    event = { 'TermOpen' },
    pattern = { 'term://*' },
    command = function()
      if vim.bo.filetype == '' or vim.bo.filetype == 'toggleterm' then
        local opts = { silent = false, buffer = 0 }
        tnoremap('<esc>', [[<C-\><C-n>]], opts)
        tnoremap('jk', [[<C-\><C-n>]], opts)
        tnoremap('<C-h>', '<Cmd>wincmd h<CR>', opts)
        tnoremap('<C-j>', '<Cmd>wincmd j<CR>', opts)
        tnoremap('<C-k>', '<Cmd>wincmd k<CR>', opts)
        tnoremap('<C-l>', '<Cmd>wincmd l<CR>', opts)
        tnoremap(']t', '<Cmd>tablast<CR>')
        tnoremap('[t', '<Cmd>tabnext<CR>')
        tnoremap('<S-Tab>', '<Cmd>bprev<CR>')
        tnoremap('<leader><Tab>', '<Cmd>close \\| :bnext<CR>')
      end
    end,
  },
})
--}}}
----------------------------------------------------------------------------------------------------
-- MACROS {{{
----------------------------------------------------------------------------------------------------
-- Absolutely fantastic function from stoeffel/.dotfiles which allows you to
-- repeat macros across a visual range
----------------------------------------------------------------------------------------------------
-- TODO: converting this to lua does not work for some obscure reason.
vim.cmd([[
  function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
  endfunction
]])

xnoremap('@', ':<C-u>call ExecuteMacroOverVisualRange()<CR>', { silent = false })
--}}}
----------------------------------------------------------------------------------------------------
-- Arrows
----------------------------------------------------------------------------------------------------
nnoremap('<down>', '<nop>')
nnoremap('<up>', '<nop>')
nnoremap('<left>', '<nop>')
nnoremap('<right>', '<nop>')
inoremap('<up>', '<nop>')
inoremap('<down>', '<nop>')
inoremap('<left>', '<nop>')
inoremap('<right>', '<nop>')
-- Repeat last substitute with flags
nnoremap('&', '<cmd>&&<CR>')
xnoremap('&', '<cmd>&&<CR>')
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
cnoremap('<C-a>', '<Home>')
cnoremap('<C-e>', '<End>')
cnoremap('<C-b>', '<Left>')
cnoremap('<C-d>', '<Del>')
cnoremap('<C-k>', [[<C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos() - 2]<CR>]])
-- move cursor one character backwards unless at the end of the command line
cnoremap('<C-f>', [[getcmdpos() > strlen(getcmdline())? &cedit: "\<Lt>Right>"]], { expr = true })
-- see :h cmdline-editing
cnoremap('<Esc>b', [[<S-Left>]])
cnoremap('<Esc>f', [[<S-Right>]])
-- Insert escaped '/' while inputting a search pattern
cnoremap('/', [[getcmdtype() == "/" ? "\/" : "/"]], { expr = true })
----------------------------------------------------------------------------------------------------
-- Save
----------------------------------------------------------------------------------------------------
local function smart_quit()
  local bufnr = api.nvim_get_current_buf()
  local buf_windows = vim.call('win_findbuf', bufnr)
  local modified = api.nvim_buf_get_option(bufnr, 'modified')
  if modified and #buf_windows == 1 then
    vim.ui.input({
      prompt = 'You have unsaved changes. Quit anyway? (y/n) ',
    }, function(input)
      if input == 'y' then vim.cmd('q!') end
    end)
    return
  end
  vim.cmd('q!')
end
-- Alternate way to save
nnoremap('<C-s>', '<cmd>silent! write<CR>')
-- Quit
nnoremap('<leader>x', smart_quit, 'quit')
-- Write and quit all files, ZZ is NOT equivalent to this
nnoremap('qa', '<cmd>qa<CR>')
----------------------------------------------------------------------------------------------------
-- Quickfix
----------------------------------------------------------------------------------------------------
nnoremap(']q', '<cmd>cnext<CR>zz')
nnoremap('[q', '<cmd>cprev<CR>zz')
nnoremap(']l', '<cmd>lnext<CR>zz')
nnoremap('[l', '<cmd>lprev<CR>zz')
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
nmap(
  'zz',
  [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']],
  { expr = true }
)
----------------------------------------------------------------------------------------------------
-- Help
----------------------------------------------------------------------------------------------------
nnoremap('<leader>ah', ':h <C-R>=expand("<cword>")<CR><CR>', 'help')
----------------------------------------------------------------------------------------------------
-- Inspect
----------------------------------------------------------------------------------------------------
nnoremap('<leader>ai', '<cmd>Inspect<CR>', 'inspect')
----------------------------------------------------------------------------------------------------
-- Move selected line / block of text in visual mode
----------------------------------------------------------------------------------------------------
xnoremap('K', ":m '<-2<CR>gv=gv")
xnoremap('J', ":m '>+1<CR>gv=gv")
----------------------------------------------------------------------------------------------------
-- Maintain cursor position when joining lines
----------------------------------------------------------------------------------------------------
nnoremap('J', 'mzJ`z')
----------------------------------------------------------------------------------------------------
-- Keep search terms in the middle
----------------------------------------------------------------------------------------------------
nnoremap('n', 'nzzzv')
nnoremap('N', 'Nzzzv')
----------------------------------------------------------------------------------------------------
-- Credit: JGunn Choi ?il | inner line
----------------------------------------------------------------------------------------------------
-- includes newline
xnoremap('al', '$o0')
onoremap('al', '<cmd>normal val<CR>')
--No Spaces or CR
xnoremap('il', [[<Esc>^vg_]])
onoremap('il', [[<cmd>normal! ^vg_<CR>]])
----------------------------------------------------------------------------------------------------
-- Add Empty space above and below
----------------------------------------------------------------------------------------------------
nnoremap('[<space>', [[<cmd>put! =repeat(nr2char(10), v:count1)<CR>'[]])
nnoremap(']<space>', [[<cmd>put =repeat(nr2char(10), v:count1)<CR>]])
-- search visual selection
vnoremap('//', [[y/<C-R>"<CR>]])
-- Credit: Justinmk
nnoremap('g>', [[<cmd>set nomore<bar>40messages<bar>set more<CR>]], 'show message history')
-- Start new line from any cursor position
inoremap('<S-Return>', '<C-o>o')
----------------------------------------------------------------------------------------------------
-- Indent
----------------------------------------------------------------------------------------------------
vnoremap('<', '<gv')
vnoremap('>', '>gv')
----------------------------------------------------------------------------------------------------
-- Buffers
----------------------------------------------------------------------------------------------------
-- Switch between the last two files
nnoremap('<leader><leader>', [[<c-^>]])
----------------------------------------------------------------------------------------------------
-- Capitalize
----------------------------------------------------------------------------------------------------
nnoremap('<leader>U', 'gUiw`]', 'capitalize word')
inoremap('<C-u>', '<cmd>norm!gUiw`]a<CR>')
-- find visually selected text
vnoremap('*', [[y/<C-R>"<CR>]])
-- make . work with visually selected lines
vnoremap('.', ':norm.<CR>')
-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap('$', 'g_')
----------------------------------------------------------------------------------------------------
-- Use alt + hjkl to resize windows
----------------------------------------------------------------------------------------------------
nnoremap('<M-j>', ':resize +2<CR>')
nnoremap('<M-k>', ':resize -2<CR>')
nnoremap('<M-l>', ':vertical resize -2<CR>')
nnoremap('<M-h>', ':vertical resize +2<CR>')
nnoremap('<leader>aF', ':vertical resize 90<CR>', 'vertical resize 90%')
nnoremap('<leader>aL', ':vertical resize 40<CR>', 'vertical resize 30%')
nnoremap('<leader>aO', ':<C-f>:resize 10<CR>', 'open old commands')
----------------------------------------------------------------------------------------------------
-- Yank from cursor position to end-of-line
nnoremap('Y', 'y$')
----------------------------------------------------------------------------------------------------
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap('0', "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true })
----------------------------------------------------------------------------------------------------
-- Add Empty space above and below
nnoremap('[<space>', [[<cmd>put! =repeat(nr2char(10), v:count1)<CR>'[]])
nnoremap(']<space>', [[<cmd>put =repeat(nr2char(10), v:count1)<CR>]])
-- replicate netrw functionality
local function open(path)
  fn.jobstart({ rvim.open_command, path }, { detach = true })
  vim.notify(fmt('Opening %s', path))
end

local function open_link()
  local file = fn.expand('<cfile>')
  if not file or fn.isdirectory(file) > 0 then return vim.cmd.edit(file) end
  if file:match('http[s]?://') then return open(file) end

  -- consider anything that looks like string/string a github link
  local plugin_url_regex = '[%a%d%-%.%_]*%/[%a%d%-%.%_]*'
  local link = string.match(file, plugin_url_regex)
  print(link)
  if link then return open(fmt('https://www.github.com/%s', link)) end
end
nnoremap('gx', open_link)
nnoremap('<leader>lq', function() rvim.toggle_qf_list() end, 'toggle quickfix')
nnoremap('<leader>lo', function() rvim.toggle_loc_list() end, 'toggle loclist')
----------------------------------------------------------------------------------------------------
-- UI Toggles
----------------------------------------------------------------------------------------------------
--- Toggle vim options
---@param opt string
local function toggle_opt(opt)
  local value = api.nvim_get_option_value(opt, {})
  if type(value) == 'number' and value == 0 then
    value = 3
  elseif type(value) == 'number' and value > 0 then
    value = 0
  elseif type(value) == 'boolean' then
    value = not value
  end
  vim.opt[opt] = value
  vim.notify(fmt('%s set to %s', opt, tostring(value)), 'info', { title = 'UI Toggles' })
end
nnoremap('<leader>ow', function() toggle_opt('wrap') end, 'toggle: wrap')
nnoremap('<leader>oL', function() toggle_opt('cursorline') end, 'toggle: cursorline')
nnoremap('<leader>os', function() toggle_opt('laststatus') end, 'toggle: statusline')
nnoremap('<leader>or', ':ToggleRelativeNumber<CR>', 'toggle: relativenumber')
----------------------------------------------------------------------------------------------------
-- Windows
----------------------------------------------------------------------------------------------------
nnoremap(
  '<localleader>wv',
  '<C-W>t <C-W>H<C-W>=',
  'change two vertically split windows to horizontal splits'
)
-- Change two vertically split windows to horizontal splits
nnoremap(
  '<localleader>wh',
  '<C-W>t <C-W>K<C-W>=',
  'change two horizontally split windows to vertical splits'
)
----------------------------------------------------------------------------------------------------
-- Folds
----------------------------------------------------------------------------------------------------
-- Make zO recursively open whatever top level fold we're in, no matter where the
-- cursor happens to be.
nnoremap('zO', [[zCzO]])
----------------------------------------------------------------------------------------------------
-- Delimiters
----------------------------------------------------------------------------------------------------
-- TLDR: Conditionally modify character at end of line
-- Description:
-- This function takes a delimiter character and:
--   * removes that character from the end of the line if the character at the end
--     of the line is that character
--   * removes the character at the end of the line if that character is a
--     delimiter that is not the input character and appends that character to
--     the end of the line
--   * adds that character to the end of the line if the line does not end with
--     a delimiter
-- Delimiters:
-- - ","
-- - ";"
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
-- Conditionally modify character at end of line
nnoremap('<localleader>,', modify_line_end_delimiter(','), 'append comma')
nnoremap('<localleader>;', modify_line_end_delimiter(';'), 'append semi colon')
nnoremap('<localleader>.', modify_line_end_delimiter('.'), 'append period')

----------------------------------------------------------------------------------------------------
-- Quick find/replace
----------------------------------------------------------------------------------------------------
nnoremap('<leader>[', [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], 'replace all')
nnoremap('<leader>]', [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], 'replace in line')
vnoremap('<leader>[', [["zy:%s/<C-r><C-o>"/]], 'replace all')
----------------------------------------------------------------------------------------------------
-- open a new file in the same directory
nnoremap('<leader>no', [[:e <C-R>=expand("%:p:h") . "/" <CR>]], 'open file in same dir')
-- create a new file in the same directory
nnoremap('<leader>nf', [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]], 'create new file in same dir')
----------------------------------------------------------------------------------------------------
-- Quotes
----------------------------------------------------------------------------------------------------
nnoremap([[<leader>"]], [[ciw"<c-r>""<esc>]], 'wrap double quotes')
nnoremap('<leader>`', [[ciw`<c-r>"`<esc>]], 'wrap backticks')
nnoremap("<leader>'", [[ciw'<c-r>"'<esc>]], 'wrap single quotes')
nnoremap('<leader>)', [[ciw(<c-r>")<esc>]], 'wrap parenthesis')
nnoremap('<leader>}', [[ciw{<c-r>"}<esc>]], 'wrap curly bracket')
----------------------------------------------------------------------------------------------------
-- Multiple Cursor Replacement
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
----------------------------------------------------------------------------------------------------
nnoremap('cn', '*``cgn')
nnoremap('cN', '*``cgN')

-- 1. Position the cursor over a word; alternatively, make a selection.
-- 2. Hit cq to start recording the macro.
-- 3. Once you are done with the macro, go back to normal mode.
-- 4. Hit Enter to repeat the macro over search matches.
function rvim.mappings.setup_map()
  nnoremap('M', [[:nnoremap M n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]])
end

vim.g.mc = rvim.replace_termcodes([[y/\V<C-r>=escape(@", '/')<CR><CR>]])
xnoremap('cn', [[g:mc . "``cgn"]], { expr = true, silent = true })
xnoremap('cN', [[g:mc . "``cgN"]], { expr = true, silent = true })
nnoremap('cq', [[:\<C-u>call v:lua.rvim.mappings.setup_map()<CR>*``qz]])
nnoremap('cQ', [[:\<C-u>call v:lua.rvim.mappings.setup_map()<CR>#``qz]])
xnoremap(
  'cq',
  [[":\<C-u>call v:lua.rvim.mappings.setup_map()<CR>gv" . g:mc . "``qz"]],
  { expr = true }
)
xnoremap(
  'cQ',
  [[":\<C-u>call v:lua.rvim.mappings.setup_map()<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
  { expr = true }
)

----------------------------------------------------------------------------------------------------
-- Command mode related
----------------------------------------------------------------------------------------------------
-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
cnoremap(
  '<Tab>',
  [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>/<C-r>/" : "<C-z>"]],
  { expr = true }
)

cnoremap(
  '<S-Tab>',
  [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>?<C-r>/" : "<S-Tab>"]],
  { expr = true }
)
-- Smart mappings on the command line
-- cnoremap("w!!", [[w !sudo tee % >/dev/null]])

-- insert path of current file into a command
cnoremap('%%', "<C-r>=fnameescape(expand('%'))<CR>")
cnoremap('::', "<C-r>=fnameescape(expand('%:p:h'))<CR>/")
----------------------------------------------------------------------------------------------------
-- Web Search
----------------------------------------------------------------------------------------------------
--- search current word in website. see usage below
---@param pat string
---@param url string
local function web_search(pat, url)
  local query = '"' .. fn.substitute(pat, '["\n]', ' ', 'g') .. '"'
  open(fmt('%s%s', url, query))
end

function rvim.mappings.ddg(pat) web_search(pat, 'https://html.duckduckgo.com/html?q=') end
function rvim.mappings.gh(pat) web_search(pat, 'https://github.com/search?q=') end

-- Search DuckDuckGo
nnoremap('<localleader>?', [[:lua rvim.mappings.ddg(vim.fn.expand("<cword>"))<CR>]], 'search')
xnoremap('<localleader>?', [["gy:lua rvim.mappings.ddg(vim.api.nvim_eval("@g"))<CR>gv]], 'search')
-- Search Github
nnoremap('<localleader>!', [[:lua rvim.mappings.gh(vim.fn.expand("<cword>"))<CR>]], 'gh search')
xnoremap('<localleader>!', [["gy:lua rvim.mappings.gh(vim.api.nvim_eval("@g"))<CR>gv]], 'gh search')
----------------------------------------------------------------------------------------------------
-- Undo
----------------------------------------------------------------------------------------------------
nnoremap('<C-z>', '<cmd>undo<CR>')
vnoremap('<C-z>', '<cmd>undo<CR><Esc>')
xnoremap('<C-z>', '<cmd>undo<CR><Esc>')
inoremap('<c-z>', [[<Esc>:undo<CR>]])
----------------------------------------------------------------------------------------------------
-- Escape
----------------------------------------------------------------------------------------------------
nnoremap('<C-c>', '<Esc>')
----------------------------------------------------------------------------------------------------
-- Window Movement
----------------------------------------------------------------------------------------------------
nnoremap('<C-h>', '<C-w>h')
nnoremap('<C-j>', '<C-w>j')
nnoremap('<C-k>', '<C-w>k')
nnoremap('<C-l>', '<C-w>l')
----------------------------------------------------------------------------------------------------
-- Buffer Movement
nnoremap('H', '<cmd>bprevious<CR>', 'previous buffer')
nnoremap('L', '<cmd>bnext<CR>', 'next buffer')
----------------------------------------------------------------------------------------------------
-- Personal
----------------------------------------------------------------------------------------------------
local function empty_registers()
  api.nvim_exec(
    [[
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
  ]],
    false
  )
end
nnoremap('<leader>aR', empty_registers, 'empty registers')
-- Search word
nnoremap('<leader>B', '/<C-R>=escape(expand("<cword>"), "/")<CR><CR>', 'find cword')
-- Greatest remap ever
vnoremap('<leader>p', '"_dP', 'greatest remap')
-- Next greatest remap ever : asbjornHaland
nnoremap('<leader>y', '"+y', 'yank')
vnoremap('<leader>y', '"+y', 'yank')
-- Paste in visual mode multiple times
xnoremap('p', 'pgvy')
-- Reverse Line
vnoremap('<leader>r', [[:s/\%V.\+\%V./\=utils#rev_str(submatch(0))<CR>gv]], 'reverse line')
-- leave extra space when deleting word
nnoremap('dw', 'cw<C-c>')
-- Select all
nnoremap('<leader>A', 'gg"+VG', 'select all')
-- Delete all
nnoremap('<leader>D', 'gg"+VGd', 'delete all')
-- Yank all
nnoremap('<leader>Y', 'gg"+yG<C-o>', 'yank all')
-- actions
nnoremap('<leader>=', '<C-W>=', 'balance window')
-- opens a horizontal split
nnoremap('<leader>H', '<C-W>s', 'horizontal split')
-- opens a vertical split
nnoremap('<leader>V', '<C-W>v', 'vsplit')
----------------------------------------------------------------------------------------------------
-- rVim {{{
----------------------------------------------------------------------------------------------------
-- FIXME: Mapping not respinding to change
nnoremap('<leader>L;', '<cmd>Alpha<CR>', 'alpha')
nnoremap('<leader>tt', '<cmd>TodoDots<CR>', 'todo: dotfiles todos')
----------------------------------------------------------------------------------------------------
-- lazy.nvim
----------------------------------------------------------------------------------------------------
-- Abbreviations
----------------------------------------------------------------------------------------------------
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
