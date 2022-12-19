if not rvim then return end

local g = vim.g
local fn = vim.fn
local api = vim.api
local fmt = string.format

local imap = rvim.imap
local nmap = rvim.nmap
local xmap = rvim.xmap
local vmap = rvim.vmap
local nnoremap = rvim.nnoremap
local xnoremap = rvim.xnoremap
local vnoremap = rvim.vnoremap
local inoremap = rvim.inoremap
local cnoremap = rvim.cnoremap
local tnoremap = rvim.tnoremap
local onoremap = rvim.onoremap

local plugin_loaded = rvim.plugin_loaded
local plugin_installed = rvim.plugin_installed

g.mapleader = (rvim.keys.leader == 'space' and ' ') or rvim.keys.leader
g.maplocalleader = (rvim.keys.localleader == 'space' and ' ') or rvim.keys.localleader

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
  local modified = api.nvim_buf_get_option(bufnr, 'modified')
  if modified then
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
-- Paste in visual mode multiple times
xnoremap('p', 'pgvy')
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
  vim.notify(opt .. ' set to ' .. tostring(value), 'info', { title = 'UI Toggles' })
end
nnoremap('<leader>ow', function() toggle_opt('wrap') end, 'toggle: wrap')
nnoremap('<leader>oc', function() toggle_opt('cursorline') end, 'toggle: cursorline')
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
nnoremap('<leader>L;', '<cmd>Alpha<CR>', 'alpha')
nnoremap(
  '<leader>Lc',
  "<cmd>lua vim.fn.execute('edit ' .. join_paths(rvim.get_user_dir(), 'config/init.lua'))<CR>",
  'open config file'
)
nnoremap('<leader>LC', '<cmd>checkhealth<CR>', 'check health')
nnoremap(
  '<leader>Ll',
  "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<CR>",
  'lsp: open logfile'
)
nnoremap('<leader>Lm', '<cmd>messages<CR>', 'messages')
nnoremap(
  '<leader>Lp',
  "<cmd>exe 'edit '.stdpath('cache').'/packer.nvim.log'<CR>",
  'packer: open logfile'
)
nnoremap(
  '<leader>Ls',
  "<cmd>lua vim.fn.execute('edit ' .. join_paths(rvim.get_cache_dir(), 'prof.log'))<CR>",
  'open startuptime logs'
)
nnoremap('<leader>Lv', ':e ' .. join_paths(rvim.get_config_dir(), 'init.lua<CR>'), 'open vimrc')
nnoremap('<leader>tt', '<cmd>TodoDots<CR>', 'todo: dotfiles todos')
----------------------------------------------------------------------------------------------------
-- Plugins {{{
----------------------------------------------------------------------------------------------------
local with_plugin = rvim.with_plugin
local with_plugin_installed = function(desc, plugin) return rvim.with_plugin(desc, plugin, true) end
----------------------------------------------------------------------------------------------------
-- packer
if plugin_installed('packer.nvim') then
  nnoremap('<leader>pc', '<cmd>PackerCompile<CR>', 'compile')
  nnoremap('<leader>pC', '<cmd>PackerClean<CR>', 'clean')
  nnoremap('<leader>pd', '<cmd>PackerDelete<CR>', 'delete packer_compiled')
  nnoremap('<leader>pe', '<cmd>PackerCompiledEdit<CR>', 'edit packer_compiled')
  nnoremap('<leader>pi', '<cmd>PackerInstall<CR>', 'install')
  nnoremap('<leader>pI', '<cmd>PackerInvalidate<CR>', 'invalidate')
  nnoremap('<leader>ps', '<cmd>PackerSync<CR>', 'sync')
  nnoremap('<leader>pS', '<cmd>PackerStatus<CR>', 'status')
  nnoremap('<leader>pu', '<cmd>PackerUpdate<CR>', 'update')
end
----------------------------------------------------------------------------------------------------
-- neotest
if plugin_installed('neotest') then
  local function neotest_open() require('neotest').output.open({ enter = true, short = false }) end
  local function run_file() require('neotest').run.run(vim.fn.expand('%')) end
  local function nearest() require('neotest').run.run() end
  local function next_failed() require('neotest').jump.prev({ status = 'failed' }) end
  local function prev_failed() require('neotest').jump.next({ status = 'failed' }) end
  local function toggle_summary() require('neotest').summary.toggle() end
  nnoremap('<localleader>ts', toggle_summary, 'neotest: run suite')
  nnoremap('<localleader>to', neotest_open, 'neotest: output')
  nnoremap('<localleader>tn', nearest, 'neotest: run')
  nnoremap('<localleader>tf', run_file, 'neotest: run file')
  nnoremap('[n', next_failed, 'jump to next failed test')
  nnoremap(']n', prev_failed, 'jump to previous failed test')
end
----------------------------------------------------------------------------------------------------
-- neogen
nnoremap(
  '<localleader>lc',
  function() require('neogen').generate() end,
  with_plugin('neogen: generate doc', 'neogen')
)
----------------------------------------------------------------------------------------------------
-- iswap.nvim
nnoremap('<leader>ia', '<Cmd>ISwap<CR>', with_plugin('iswap: swap any', 'iswap.nvim'))
nnoremap('<leader>iw', '<Cmd>ISwapWith<CR>', with_plugin('iswap: swap with', 'iswap.nvim'))
----------------------------------------------------------------------------------------------------
-- fold-cycle.nvim
nnoremap(
  '<BS>',
  function() require('fold-cycle').open() end,
  with_plugin('fold-cycle: open', 'fold-cycle.nvim')
)
----------------------------------------------------------------------------------------------------
-- vim-easy-align
nmap('ga', '<Plug>(EasyAlign)', with_plugin('easy-align: align', 'vim-easy-align'))
xmap('ga', '<Plug>(EasyAlign)', with_plugin('easy-align: align', 'vim-easy-align'))
vmap('<Enter>', '<Plug>(EasyAlign)', with_plugin('easy-align: align', 'vim-easy-align'))
----------------------------------------------------------------------------------------------------
-- marks.nvim
nnoremap('<leader>mb', '<Cmd>MarksListBuf<CR>', with_plugin('marks: list buffer', 'marks.nvim'))
nnoremap(
  '<leader>mg',
  '<Cmd>MarksQFListGlobal<CR>',
  with_plugin('marks: list global', 'marks.nvim')
)
nnoremap(
  '<leader>m0',
  '<Cmd>BookmarksQFList 0<CR>',
  with_plugin('marks: list bookmark', 'marks.nvim')
)
----------------------------------------------------------------------------------------------------
-- null-ls.nvim
nnoremap('<leader>ln', '<cmd>NullLsInfo<CR>', with_plugin('null-ls: info', 'null-ls.nvim'))
----------------------------------------------------------------------------------------------------
-- nvim-treesitter
nnoremap(
  'R',
  '<cmd>edit | TSBufEnable highlight<CR>',
  with_plugin('treesitter: enable highlight', 'nvim-treesitter')
)
nnoremap('<leader>Le', '<cmd>TSInstallInfo<CR>', with_plugin('treesitter: info', 'nvim-treesitter'))
nnoremap(
  '<leader>Lm',
  '<cmd>TSModuleInfo<CR>',
  with_plugin('treesitter: module info', 'nvim-treesitter')
)
nnoremap('<leader>Lu', '<cmd>TSUpdate<CR>', with_plugin('treesitter: update', 'nvim-treesitter'))
----------------------------------------------------------------------------------------------------
-- lsp_lines.nvim
nnoremap(
  '<leader>ol',
  function() require('lsp_lines').toggle() end,
  with_plugin('lsp_lines.nvim', 'lsp_lines: toggle')
)
----------------------------------------------------------------------------------------------------
-- nvim-dap
if plugin_loaded('nvim-dap') then
  local dap = require('dap')
  local dap_utils = require('user.utils.dap')
  local function repl_toggle() dap.repl.toggle(nil, 'botright split') end
  local function set_breakpoint() dap.set_breakpoint(fn.input('Breakpoint condition: ')) end
  rvim.nnoremap('<localleader>db', dap.toggle_breakpoint, 'dap: toggle breakpoint')
  rvim.nnoremap('<localleader>dB', set_breakpoint, 'dap: set breakpoint')
  rvim.nnoremap('<localleader>dc', dap.continue, 'dap: continue or start debugging')
  rvim.nnoremap('<localleader>dC', dap.clear_breakpoints, 'dap: clear breakpoint')
  rvim.nnoremap('<localleader>dh', dap.step_back, 'dap: step back')
  rvim.nnoremap('<localleader>de', dap.step_out, 'dap: step out')
  rvim.nnoremap('<localleader>di', dap.step_into, 'dap: step into')
  rvim.nnoremap('<localleader>do', dap.step_over, 'dap: step over')
  rvim.nnoremap('<localleader>dl', dap.run_last, 'dap: run last')
  rvim.nnoremap('<localleader>dr', dap.restart, 'dap: restart')
  rvim.nnoremap('<localleader>dx', dap.terminate, 'dap: terminate')
  rvim.nnoremap('<localleader>dt', repl_toggle, 'dap REPL: toggle')
  rvim.nnoremap('<localleader>da', dap_utils.attach, 'dap(node): attach')
  rvim.nnoremap('<localleader>dA', dap_utils.attach_to_remote, 'dap(node): attach to remote')
end
----------------------------------------------------------------------------------------------------
-- nvim-dap-ui
nnoremap(
  '<localleader>dT',
  function() require('dapui').toggle({ reset = true }) end,
  with_plugin('dapui: toggle', 'nvim-dap-ui')
)
----------------------------------------------------------------------------------------------------
-- undotree
nnoremap(
  '<leader>u',
  '<cmd>UndotreeToggle<CR>',
  with_plugin_installed('undotree: toggle', 'undotree')
)
----------------------------------------------------------------------------------------------------
-- auto-session
nnoremap(
  '<leader>ss',
  '<cmd>RestoreSession<CR>',
  with_plugin('auto-session: restore', 'auto-session')
)
nnoremap('<leader>sl', '<cmd>SaveSession<CR>', with_plugin('auto-session: save', 'auto-session'))
----------------------------------------------------------------------------------------------------
-- harpoon
if plugin_loaded('harpoon') then
  local ui = require('harpoon.ui')
  local m = require('harpoon.mark')
  nnoremap('<leader>ma', m.add_file, 'harpoon: add')
  nnoremap('<leader>m.', ui.nav_next, 'harpoon: next')
  nnoremap('<leader>m,', ui.nav_prev, 'harpoon: prev')
  nnoremap('<leader>m;', ui.toggle_quick_menu, 'harpoon: ui')
  if not plugin_loaded('telescope.nvim') then return end
  local function harpoon_marks()
    require('telescope').extensions.harpoon.marks(
      rvim.telescope.minimal_ui({ prompt_title = 'Harpoon Marks' })
    )
  end
  nnoremap('<leader>mm', harpoon_marks, 'harpoon: marks')
  nnoremap('<leader>mf', '<cmd>Telescope harpoon marks<CR>', 'telescope: harpoon search')
end
----------------------------------------------------------------------------------------------------
-- mason.nvim
nnoremap('<leader>lm', '<cmd>Mason<CR>', with_plugin_installed('mason: info', 'mason.nvim'))
----------------------------------------------------------------------------------------------------
-- jaq.nvim
nnoremap('<C-b>', ':silent only | Jaq<CR>', with_plugin_installed('jaq: run', 'jaq-nvim'))
----------------------------------------------------------------------------------------------------
-- cheat-sheet
nnoremap('<localleader>s', '<cmd>CheatSH<CR>', with_plugin('cheat-sheet: search', 'cheat-sheet'))
----------------------------------------------------------------------------------------------------
-- inc-rename.nvim
nnoremap(
  '<leader>rn',
  function() return ':IncRename ' .. vim.fn.expand('<cword>') end,
  { expr = true, silent = false, desc = 'inc-rename: inc rename', plugin = 'inc-rename.nvim' }
)
----------------------------------------------------------------------------------------------------
-- sniprun
nnoremap('<leader>sr', '<cmd>SnipRun<CR>', with_plugin('sniprun: run', 'sniprun'))
vnoremap('<leader>sr', '<cmd>SnipRun<CR>', with_plugin('sniprun: run', 'sniprun'))
nnoremap('<leader>sc', '<cmd>SnipClose<CR>', with_plugin('sniprun: close', 'sniprun'))
nnoremap('<leader>sx', '<cmd>SnipReset<CR>', with_plugin('sniprun: reset', 'sniprun'))
----------------------------------------------------------------------------------------------------
-- diffview.nvim
nnoremap('<localleader>gd', '<cmd>DiffviewOpen<CR>', with_plugin('diffview: open', 'diffview.nvim'))
nnoremap(
  '<localleader>gh',
  '<Cmd>DiffviewFileHistory<CR>',
  with_plugin('diffview: file history', 'diffview.nvim')
)
vnoremap(
  'gh',
  [[:'<'>DiffviewFileHistory<CR>]],
  with_plugin('diffview: file history', 'diffview.nvim')
)
----------------------------------------------------------------------------------------------------
-- vim-illuminate
nnoremap(
  '<a-n>',
  ':lua require"illuminate".next_reference{wrap=true}<CR>',
  with_plugin('illuminate: next', 'vim-illuminate')
)
nnoremap(
  '<a-p>',
  ':lua require"illuminate".next_reference{reverse=true,wrap=true}<CR>',
  with_plugin('illuminate: reverse', 'vim-illuminate')
)
----------------------------------------------------------------------------------------------------
-- cybu.nvim
if plugin_installed('cybu.nvim') then
  nnoremap('H', '<Plug>(CybuPrev)', 'cybu: prev')
  nnoremap('L', '<Plug>(CybuNext)', 'cybu: next')
else
  nnoremap('H', '<cmd>bprevious<CR>', 'previous buffer')
  nnoremap('L', '<cmd>bnext<CR>', 'next buffer')
end
----------------------------------------------------------------------------------------------------
-- FTerm.nvim
if plugin_loaded('FTerm.nvim') then
  local function new_float(cmd)
    cmd = require('FTerm'):new({ cmd = cmd, dimensions = { height = 0.9, width = 0.9 } }):toggle()
  end
  nnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
  tnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
  nnoremap('<leader>lg', function() new_float('lazygit') end, 'fterm: toggle lazygit')
  nnoremap('<leader>ga', function() new_float('git add .') end, 'git: add all')
  nnoremap('<leader>gc', function() new_float('git commit -a -v') end, 'git: commit')
  nnoremap(
    '<leader>gd',
    function() new_float('iconf -ccma') end,
    with_plugin('git: commit dotfiles', 'FTerm.nvim')
  )
  nnoremap('<leader>tb', function() new_float('btop') end, 'fterm: btop')
  nnoremap('<leader>tn', function() new_float('node') end, 'fterm: node')
  nnoremap('<leader>tr', function() new_float('ranger') end, 'fterm: ranger')
  nnoremap('<leader>tp', function() new_float('python') end, 'fterm: python')
end
----------------------------------------------------------------------------------------------------
-- toggleterm.nvim
if plugin_loaded('toggleterm.nvim') then
  local new_term = function(direction, key, count)
    local Terminal = require('toggleterm.terminal').Terminal
    local cmd = fmt('<cmd>%sToggleTerm direction=%s<CR>', count, direction)
    return Terminal:new({
      direction = direction,
      on_open = function() vim.cmd('startinsert!') end,
      nnoremap(key, cmd),
      inoremap(key, cmd),
      tnoremap(key, cmd),
      count = count,
    })
  end
  local float_term = new_term('float', '<f2>', 1)
  local vertical_term = new_term('vertical', '<F3>', 2)
  local horizontal_term = new_term('horizontal', '<F4>', 3)
  nnoremap('<f2>', function() float_term:toggle() end)
  inoremap('<f2>', function() float_term:toggle() end)
  nnoremap('<F3>', function() vertical_term:toggle() end)
  inoremap('<F3>', function() vertical_term:toggle() end)
  nnoremap('<F4>', function() horizontal_term:toggle() end)
  inoremap('<F4>', function() horizontal_term:toggle() end)
end
----------------------------------------------------------------------------------------------------
-- telescope.nvim
if plugin_loaded('telescope.nvim') then
  local builtin = require('telescope.builtin')
  nnoremap('<leader>fb', builtin.current_buffer_fuzzy_find, 'find in current buffer')
  nnoremap('<leader>fR', builtin.reloader, 'module reloader')
  nnoremap('<leader>fw', builtin.grep_string, 'find current word')
  nnoremap('<leader>fs', builtin.live_grep, 'find string')
  nnoremap('<leader>fva', builtin.autocommands, 'autocommands')
  nnoremap('<leader>fvh', builtin.highlights, 'highlights')
  nnoremap('<leader>fvk', builtin.keymaps, 'keymaps')
  nnoremap('<leader>fvo', builtin.vim_options, 'options')
  nnoremap('<leader>fvr', builtin.resume, 'resume')
  -- Git
  nnoremap('<leader>gf', builtin.git_files, 'git: files')
  nnoremap('<leader>gs', builtin.git_status, 'git: status')
  nnoremap('<leader>fgb', builtin.git_branches, 'git: branches')
  -- LSP
  nnoremap('<leader>lR', '<cmd>Telescope lsp_references<CR>', 'telescope: references')
  nnoremap('<leader>ld', '<cmd>Telescope lsp_document_symbols<CR>', 'telescope: document symbols')
  nnoremap(
    '<leader>le',
    '<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<CR>',
    'telescope: document diagnostics'
  )
  nnoremap(
    '<leader>lE',
    '<cmd>Telescope diagnostics theme=get_ivy<CR>',
    'telescope: workspace diagnostics'
  )
  nnoremap(
    '<leader>ls',
    '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>',
    'telescope: workspace symbols'
  )
end
----------------------------------------------------------------------------------------------------
-- bracey.vim
nnoremap('<leader>bs', '<cmd>Bracey<CR>', with_plugin('bracey: start', 'bracey.vim'))
nnoremap('<leader>be', '<cmd>BraceyStop<CR>', with_plugin('bracey: stop', 'bracey.vim'))
----------------------------------------------------------------------------------------------------
-- Comment.nvim
nnoremap(
  '<leader>/',
  '<Plug>(comment_toggle_linewise_current)',
  with_plugin('comment: toggle current line', 'Comment.nvim')
)
xnoremap(
  '<leader>/',
  '<Plug>(comment_toggle_linewise_visual)',
  with_plugin('comment: toggle linewise', 'Comment.nvim')
)
----------------------------------------------------------------------------------------------------
-- nvim-toggler
nnoremap(
  '<leader>ii',
  '<cmd>lua require("nvim-toggler").toggle()<CR>',
  with_plugin_installed('nvim-toggler: toggle', 'nvim-toggler')
)
----------------------------------------------------------------------------------------------------
-- nvim-notify
nnoremap('<leader>nn', '<cmd>Notifications<CR>', with_plugin('notify: show', 'nvim-notify'))
nnoremap(
  '<leader>nx',
  '<cmd>lua require("notify").dismiss()<CR>',
  with_plugin('notify: dismiss', 'nvim-notify')
)
----------------------------------------------------------------------------------------------------
-- LuaSnip
nnoremap('<leader>S', '<cmd>LuaSnipEdit<CR>', with_plugin('LuaSnip: edit snippet', 'LuaSnip'))
----------------------------------------------------------------------------------------------------
-- neo-tree.nvim
nnoremap('<leader>e', '<Cmd>Neotree toggle reveal<CR>', with_plugin('toggle tree', 'neo-tree.nvim'))
----------------------------------------------------------------------------------------------------
-- playground
nnoremap(
  '<leader>LE',
  ':TSHighlightCapturesUnderCursor<CR>',
  with_plugin_installed('playground: inspect scope', 'playground')
)
----------------------------------------------------------------------------------------------------
-- spread.nvim
nnoremap(
  'gS',
  function() require('spread').out() end,
  with_plugin_installed('spread: expand', 'spread.nvim')
)
nnoremap(
  'gJ',
  function() require('spread').combine() end,
  with_plugin_installed('spread: combine', 'spread.nvim')
)
----------------------------------------------------------------------------------------------------
-- close-buffers.nvim
if plugin_installed('close-buffers.nvim') then
  local cb = require('close_buffers')
  nnoremap('<leader>c', function() cb.wipe({ type = 'this' }) end, 'close buffer')
  nnoremap('<leader>bc', function() cb.wipe({ type = 'other' }) end, 'close others')
  nnoremap('<leader>bx', function() cb.wipe({ type = 'all', force = true }) end, 'close others')
end
----------------------------------------------------------------------------------------------------
-- buffer_manager.nvim
local buffer_manager = require('buffer_manager.ui')
nnoremap(
  '<tab>',
  buffer_manager.toggle_quick_menu,
  with_plugin_installed('buffer_manager: toggle', 'local-buffer_manager.nvim')
)
----------------------------------------------------------------------------------------------------
-- no-neck-pain.nvim
nnoremap(
  '<leader>on',
  '<cmd>lua require("no-neck-pain").start()<CR>',
  with_plugin_installed('no-neck-pain: toggle', 'no-neck-pain.nvim')
)

----------------------------------------------------------------------------------------------------
-- todo-comments.nvim
nnoremap(
  '<leader>tj',
  function() require('todo-comments').jump_next() end,
  with_plugin('todo-comments: next todo', 'todo-comments.nvim')
)
nnoremap(
  '<leader>tk',
  function() require('todo-comments').jump_prev() end,
  with_plugin('todo-comments: prev todo', 'todo-comments.nvim')
)
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
