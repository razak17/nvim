local enabled = ar_config.plugin.main.mappings.enable

if not ar or ar.none or not enabled then return end

local fn, api, fmt = vim.fn, vim.api, string.format
local is_available = ar.is_available
local command = ar.command

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
-- local onoremap = function(...) map('o', ...) end
local cnoremap = function(...) map('c', ...) end

ar.mappings = {}

--------------------------------------------------------------------------------
-- MACROS {{{
--------------------------------------------------------------------------------
-- repeat macros across a visual range
xnoremap('@', function()
  vim.ui.input(
    { prompt = 'Macro Register: ' },
    function(reg) vim.cmd([['<,'>normal @]] .. reg) end
  )
end, { silent = false })
-----------------------------------------------------------------------------//
-- Add Empty space above and below
-----------------------------------------------------------------------------//
nnoremap('[<space>', [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>]], {
  desc = 'add space above',
})
nnoremap(']<space>', [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]], {
  desc = 'add space below',
})
--------------------------------------------------------------------------------
-- Clipboard
--------------------------------------------------------------------------------
-- Delete a single character without copying into register:
nnoremap('<leader>x', '"_x', { desc = 'delete char (no copy)' })
-- Greatest remap ever
vnoremap('<leader>p', '"_dP', { desc = 'greatest remap' })
-- Keep cursor position on paste
-- nnoremap('p', function()
--   local row, col = unpack(api.nvim_win_get_cursor(0))
--   vim.cmd('put')
--   api.nvim_win_set_cursor(0, { row + 1, col })
-- end)
-- Next greatest remap ever : asbjornHaland
map({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'yank' })
map({ 'n', 'x' }, '<leader>Y', '"_Y', { desc = 'yank' })
map({ 'n', 'x' }, '<leader>d', '"_d', { desc = 'delete' })
map({ 'n', 'x' }, '<leader>D', '"_D', { desc = 'Delete' })
map({ 'n', 'x' }, '<leader>c', '"_c', { desc = 'cut' })
map({ 'n', 'x' }, '<leader>C', '"_C', { desc = 'cut' })
-- nnoremap('<localleader>vc', ':let @+=@:<cr>', { desc = 'yank last ex command text' })
-- nnoremap(
--  '<localleader>vm',
--   [[:let @+=substitute(execute('messages'), '\n\+', '\n', 'g')<cr>]],
--   { desc = 'yank vim messages output' }
-- )
--------------------------------------------------------------------------------
-- Credit: JGunn Choi ?il | inner line
----------------------------------------------------------------------------
-- Yank all
nnoremap('<localleader>Y', ':%y+<CR>', { desc = 'yank all' })
-- Select all
nnoremap('<localleader>A', 'gg"+VG', { desc = 'select all' })
-- Delete All
nnoremap('<localleader>D', ':%d<CR>', { desc = 'delete all' })
--- Paste commands
map('n', '<localleader>P', 'ggVG"_dP', { desc = 'paste over entire file' })
-- Paste in visual mode multiple times
xnoremap('p', 'pgvy')
-- search visual selection
vnoremap('//', [[y/<C-R>"<CR>]])
-- show message history
nnoremap('g>', [[<cmd>set nomore<bar>40messages<bar>set more<CR>]])
-- Enter key should repeat the last macro recorded or just act as enter
nnoremap(
  '<leader><CR>',
  [[empty(&buftype) ? '@@':'<CR>']],
  { expr = true, desc = 'repeat macro' }
)
-- Evaluates whether there is a fold on the current line if so unfold it else return a normal space
-- nnoremap('<space><space>', [[@=(foldlevel('.')?'za':"\<Space>")<CR>]], { desc = 'toggle fold' })
-- Make zO recursively open whatever top level fold we're in, no matter where the
-- cursor happens to be.
nnoremap('zO', [[zCzO]])
-- nnoremap('<tab>', [[za]])
--------------------------------------------------------------------------------
-- Delimiters
--------------------------------------------------------------------------------
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

nnoremap(
  '<localleader>,',
  modify_line_end_delimiter(','),
  { desc = 'append comma' }
)
nnoremap(
  '<localleader>;',
  modify_line_end_delimiter(';'),
  { desc = 'append semi colon' }
)
-- @see: https://castel.dev/post/lecture-notes-1/#correcting-spelling-mistakes-on-the-fly
inoremap(
  '<C-s>',
  '<C-g>u<ESC>[s1z=`]a<C-g>u',
  { desc = 'fix nearest spelling error and put the cursor back' }
)
--------------------------------------------------------------------------------
-- Capitalize
nnoremap('<leader>uu', 'gUiw', { desc = 'capitalize word' })
--------------------------------------------------------------------------------
-- Moving lines/visual block
xnoremap('K', ":m '<-2<CR>gv=gv")
xnoremap('J', ":m '>+1<CR>gv=gv")
--------------------------------------------------------------------------------
-- Windows
--------------------------------------------------------------------------------
-- change two vertically split windows to horizontal splits
nnoremap(
  '<leader>wv',
  '<C-W>t <C-W>H<C-W>=',
  { desc = 'horizontal to vertical' }
)
-- change two horizontally split windows to vertical splits
nnoremap(
  '<leader>wh',
  '<C-W>t <C-W>K<C-W>=',
  { desc = 'vertical to horizontal' }
)
-- make . work with visually selected lines
vnoremap('.', ':norm.<CR>')
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
-----------------------------------------------------------------------------//
-- Quick find/replace
-----------------------------------------------------------------------------//
local function replace_word(transform_fn, prompt_suffix, edit)
  return function()
    local value = fn.expand('<cword>')
    local default_value = transform_fn(value)
    vim.ui.input({
      prompt = 'Replace word with ' .. prompt_suffix,
      default = edit and default_value or '',
    }, function(new_value)
      if not new_value then return end
      vim.cmd('%s/' .. value .. '/' .. transform_fn(new_value) .. '/gI')
    end)
  end
end
nnoremap(
  '<leader>[[',
  replace_word(function(x) return x end, ''),
  { desc = 'replace word in file' }
)
nnoremap(
  '<leader>[e',
  replace_word(function(x) return x end, '', true),
  { desc = 'edit word in file' }
)
nnoremap(
  '<leader>[u',
  replace_word(fn.toupper, 'UPPERCASE'),
  { desc = 'replace word in file with UPPERCASE' }
)
nnoremap(
  '<leader>[l',
  replace_word(fn.tolower, 'lowercase'),
  { desc = 'replace word in file with lowercase' }
)
vnoremap('<leader>[[', [["zy:%s/<C-r><C-o>"/]], { desc = 'replace all' })
--------------------------------------------------------------------------------
-- Visual shifting (does not exit Visual mode)
vnoremap('<', '<gv')
vnoremap('>', '>gv')
--------------------------------------------------------------------------------
-- open a new file in the same directory
nnoremap(
  '<leader>no',
  [[:e <C-R>=expand("%:p:h") . "/" <CR>]],
  { desc = 'open file' }
)
-- create a new file in the same directory
local function new_file_in_current_dir()
  vim.ui.input({
    prompt = 'New file name: ',
    default = '',
    completion = 'file',
  }, function(file)
    if not file or file == '' then return end
    vim.cmd('e ' .. fn.expand('%:p:h') .. '/' .. file)
  end)
end
nnoremap('<leader>nf', new_file_in_current_dir, { desc = 'create new file' })
--------------------------------------------------------------------------------
-- Make the file you run the command on, executable, so you don't have to go out to the command line
-- https://github.com/linkarzu/dotfiles-latest/blob/66c7304d34c713e8c7d6066d924ac2c3a9c0c9e8/neovim/neobean/lua/config/keymaps.lua?plain=1#L131
nnoremap(
  '<leader><leader>fx',
  '<Cmd>!chmod +x "%"<CR>',
  { silent = true, desc = 'make file executable' }
)
nnoremap(
  '<leader><leader>fX',
  '<Cmd>!chmod -x "%"<CR>',
  { silent = true, desc = 'remove executable flag' }
)
--------------------------------------------------------------------------------
-- Arrows
nnoremap('<down>', '<nop>')
nnoremap('<up>', '<nop>')
nnoremap('<left>', '<nop>')
nnoremap('<right>', '<nop>')
inoremap('<up>', '<nop>')
inoremap('<down>', '<nop>')
inoremap('<left>', '<nop>')
inoremap('<right>', '<nop>')
--------------------------------------------------------------------------------
-- Commandline mappings
--------------------------------------------------------------------------------
-- https://github.com/tpope/vim-rsi/blob/master/plugin/rsi.vim
-- c-a / c-e everywhere - RSI.vim provides these
cnoremap('<C-n>', '<Down>')
cnoremap('<C-p>', '<Up>')
-- <C-A> allows you to insert all matches on the command line e.g. bd *.js <c-a>
-- will insert all matching files e.g. :bd a.js b.js c.js
cnoremap('<c-x><c-a>', '<c-a>')
-- move cursor one character backwards unless at the end of the command line
cnoremap('<M-f>', function()
  if fn.getcmdpos() == fn.strlen(fn.getcmdline()) then return '<c-f>' end

  return '<Right>'
end, { expr = true })
cnoremap('<C-b>', '<Left>')
cnoremap('<C-d>', '<Del>')

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
local function search(direction_key, default)
  local c_type = fn.getcmdtype()
  return (c_type == '/' or c_type == '?') and fmt('<CR>%s<C-r>/', direction_key)
    or default
end
cnoremap('<Tab>', function() return search('/', '<Tab>') end, { expr = true })
cnoremap(
  '<S-Tab>',
  function() return search('?', '<S-Tab>') end,
  { expr = true }
)
-- insert path of current file into a command
cnoremap(';p', "<C-r>=fnameescape(expand('%:p:h'))<cr>/")
cnoremap(';;', "<C-r>=fnameescape(expand('%:h'))<cr>/")
--------------------------------------------------------------------------------
-- NOTE: this uses write specifically because we need to trigger a filesystem event
-- even if the file isn't changed so that things like hot reload work
nnoremap('<c-s>', '<Cmd>silent! write ++p<CR>')
-- Buffer Management
if not is_available('cybu.nvim') then
  nnoremap('gB', '<cmd>bprevious<CR>', { desc = 'previous buffer' })
  nnoremap('gP', '<cmd>bnext<CR>', { desc = 'next buffer' })
end
if not is_available('close-buffers.nvim') then
  nnoremap('<leader>qb', ':bdel<CR>', { desc = 'delete buffer' })
end
if not is_available('neo-tree.nvim') then
  nnoremap('<C-n>', ':Ex<CR>', { desc = 'explorer' })
end
nnoremap('<localleader>bo', function()
  local current_buffer = fn.bufnr('%')
  for _, buffer in ipairs(fn.getbufinfo({ buflisted = 1 })) do
    if buffer.bufnr ~= current_buffer then
      api.nvim_buf_delete(buffer.bufnr, {})
    end
  end
end, { desc = 'close other buffers' })
nnoremap('<leader>od', function()
  if fn.confirm('Delete file?', '&Yes\n&No') == 1 then
    ar_config.autosave.enable = not ar_config.autosave.enable
    local file = fn.expand('%:p')
    ar.trash_file(file, true)
    vim.cmd('bdel')
    ar_config.autosave.enable = not ar_config.autosave.enable
  end
end, { desc = 'trash file' })
nnoremap('<leader>oD', function()
  if fn.confirm('Delete file?', '&Yes\n&No') == 1 then vim.cmd('Delete!') end
end, { desc = 'delete file' })
nnoremap(
  '<leader>X',
  ':wqall<CR>',
  { desc = 'save all and quit', silent = true }
)
nnoremap('<leader>wq', '<cmd>:q<cr>', { desc = 'close window', silent = true })
nnoremap('<leader>wt', '<C-w>T', { desc = 'move to new tab' })
nnoremap('<leader>qq', ':q<CR>', { desc = 'quit', silent = true })
nnoremap('<leader>Q', ':qa!<CR>', { desc = 'force quit all', silent = true })
nnoremap(
  '<localleader>Q',
  ':cq<CR>',
  { desc = 'restart editor', silent = true }
)
-- commenting
nnoremap(
  'gco',
  'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>',
  { desc = 'add comment below' }
)
nnoremap(
  'gcO',
  'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>',
  { desc = 'add comment above' }
)
--------------------------------------------------------------------------------
-- ?ie | entire object
--------------------------------------------------------------------------------
-- xnoremap('ie', [[gg0oG$]])
-- onoremap('ie', [[<cmd>execute "normal! m`"<Bar>keepjumps normal! ggVG<CR>]])
--------------------------------------------------------------------------------
-- Core navigation
--------------------------------------------------------------------------------
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap(
  '0',
  "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'",
  { expr = true }
)
-- use gh to move to the beginning of the line in normal mode
-- use gl to move to the end of the line in normal mode
map(
  { 'n', 'x' },
  'gh',
  "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'",
  { expr = true, desc = 'go to start of line' }
)
-- map({ 'n', 'x' }, 'gl', '$', { desc = 'go to the end of the line' })
-- In visual mode, after going to the end of the line, come back 1 character
map({ 'x' }, 'gl', '$h', { desc = 'go to end of line' })
-- when going to the end of the line in visual mode ignore whitespace characters
-- vnoremap('$', 'g_')
-- jk is escape, THEN move to the right to preserve the cursor position, unless
-- at the first column.  <esc> will continue to work the default way.
-- NOTE: this is a recursive mapping so anything bound (by a plugin) to <esc> still works
if ar.plugins.minimal then
  imap('jk', [[col('.') == 1 ? '<esc>' : '<esc>l']], { expr = true })
  imap('kj', [[col('.') == 1 ? '<esc>' : '<esc>l']], { expr = true })
end
-- Toggle top/center/bottom
nmap(
  'zz',
  [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']],
  { expr = true }
)
-- Escape
nnoremap('<C-c>', '<Esc>')
--------------------------------------------------------------------------------
-- Web Search
--------------------------------------------------------------------------------
function ar.mappings.ddg(path)
  ar.web_search(path, 'https://html.duckduckgo.com/html?q=')
end
function ar.mappings.gh(path)
  ar.web_search(path, 'https://github.com/search?q=')
end

-- Search DuckDuckGo
nnoremap(
  '<localleader>?',
  [[:lua ar.mappings.ddg(vim.fn.expand("<cword>"))<CR>]],
  { desc = 'search word' }
)
xnoremap(
  '<localleader>?',
  [["gy:lua ar.mappings.ddg(vim.api.nvim_eval("@g"))<CR>gv]],
  { desc = 'search word' }
)
-- Search Github
nnoremap(
  '<localleader>!',
  [[:lua ar.mappings.gh(vim.fn.expand("<cword>"))<CR>]],
  { desc = 'gh search word' }
)
xnoremap(
  '<localleader>!',
  [["gy:lua ar.mappings.gh(vim.api.nvim_eval("@g"))<CR>gv]],
  { desc = 'gh search word' }
)
--------------------------------------------------------------------------------
-- GX - replicate netrw functionality
--------------------------------------------------------------------------------
if
  (ar_config.gx.enable and ar_config.gx.variant == 'local')
  or ar.plugins.minimal
then
  map('n', 'gx', function()
    -- ref: https://github.com/theopn/theovim/blob/main/lua/core.lua#L178
    -- Find the URL in the current line and open it in a browser
    local line = fn.getline('.')
    local url = string.match(line, '[a-z]*://[^ >,;)"\']*')
    if url then return ar.open(url, true) end
    local file = fn.expand('<cfile>')
    if not file or fn.isdirectory(file) > 0 then return vim.cmd.edit(file) end
    if file:match('http[s]?://') then return ar.open(file, true) end
    -- consider anything that looks like string/string a github link
    local plugin_url_regex = '[%a%d%-%.%_]*%/[%a%d%-%.%_]*'
    local link = string.match(file, plugin_url_regex)
    if link then
      return ar.open(fmt('https://www.github.com/%s', link), true)
    end
  end, { desc = 'open link' })
end
--------------------------------------------------------------------------------
nnoremap('<leader>lq', ar.list.qf.toggle, { desc = 'toggle quickfix list' })
nnoremap('<leader>lL', ar.list.loc.toggle, { desc = 'toggle location list' })
nnoremap('<leader>j', '<Cmd>cnext<CR>', { desc = 'qflist next' })
nnoremap('<leader>k', '<Cmd>cprev<CR>', { desc = 'qflist previous' })
nnoremap('<localleader>j', '<Cmd>lnext<CR>', { desc = 'loclist next' })
nnoremap('<localleader>k', '<Cmd>lprev<CR>', { desc = 'loclist previous' })
--------------------------------------------------------------------------------
-- Completion
--------------------------------------------------------------------------------
-- cycle the completion menu with <TAB>
inoremap('<tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
inoremap('<s-tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
--------------------------------------------------------------------------------
-- Help
nnoremap(
  '<leader>H',
  ':h <C-R>=expand("<cword>")<CR><CR>',
  { desc = 'help', silent = true }
)
-- Visual mode help
local function visual_help()
  local text = ar.get_visual_text()
  vim.cmd('help ' .. text)
end
xnoremap('<leader>ah', visual_help, { desc = 'visual help' })
--------------------------------------------------------------------------------
-- Undo
-- nnoremap('<C-z>', '<cmd>undo<CR>')
vnoremap('<C-z>', '<cmd>undo<CR><Esc>')
xnoremap('<C-z>', '<cmd>undo<CR><Esc>')
inoremap('<c-z>', [[<Esc>:undo<CR>]])
--------------------------------------------------------------------------------
-- Reverse Line
function ar.rev_str(str) return string.reverse(str) end
vnoremap(
  '<localleader>ur',
  [[:s/\%V.\+\%V./\=v:lua.ar.rev_str(submatch(0))<CR>gv<ESC>]],
  { desc = 'reverse line' }
)
--------------------------------------------------------------------------------
-- Remove empty lines
xnoremap('<leader>ul', [[:g/\v^ *$/d<CR>]], { desc = 'remove empty lines' })
--------------------------------------------------------------------------------
nnoremap('<leader>ui', vim.show_pos, { desc = 'inspect pos' })
nnoremap('<leader>uI', '<cmd>Inspect<CR>', { desc = 'inspect tree' })
--------------------------------------------------------------------------------
-- Inspect treesitter tree
nnoremap(
  '<leader>ut',
  function() vim.treesitter.inspect_tree({ command = 'botright 60vnew' }) end,
  { desc = 'inspect tree' }
)
--------------------------------------------------------------------------------
-- Conceal Level & Cursor
nnoremap(
  '<localleader>cl',
  ':lua require"ar.menus.toggle".toggle_conceal_level()<CR>',
  { desc = 'toggle conceallevel', silent = true }
)
nnoremap(
  '<localleader>cc',
  ':lua require"ar.menus.toggle".toggle_conceal_cursor()<CR>',
  { desc = 'toggle concealcursor', silent = true }
)
--------------------------------------------------------------------------------
-- Open in finder
nnoremap('<leader><localleader>fo', function()
  local file_path = vim.fn.expand('%:p')
  ar.open_in_file_manager(file_path)
end, { desc = 'open in file manager' })
--------------------------------------------------------------------------------
-- Ruslings
nnoremap('<leader><localleader>rd', function()
  vim.cmd([[%s/\n\n\/\/ I AM NOT DONE//]])
  vim.cmd.w()
end, { desc = 'rustlings: done' })
nnoremap('<leader><localleader>rn', function()
  local cur = fn.expand('%')
  local num = cur:sub(-4, -4)
  local next = cur:sub(1, -5) .. (num + 1) .. '.rs'
  if fn.filereadable(next) == 1 then
    vim.cmd('bd')
    vim.cmd('edit ' .. next)
  else
    print('All problems solved for this topic.')
  end
end, { desc = 'rustlings: next' })
--------------------------------------------------------------------------------
-- Dump messages in buffer
-- https://www.reddit.com/r/neovim/comments/1dyngff/a_lua_script_to_dump_messages_to_a_buffer_for/
local function dump()
  local tmpname = fn.tempname()
  vim.g._messages = ''
  vim.schedule(function()
    vim.cmd('redir => g:_messages')
    vim.cmd('silent! messages')
    vim.cmd('redir END')
    local file = io.open(tmpname, 'w')
    if file then
      file:write(vim.trim(vim.g._messages))
      file:close()
    end
    vim.cmd('vsp ' .. tmpname)
    vim.cmd('wincmd l')
    vim.g._messages = nil
  end)
end
nnoremap('<localleader>mm', dump, { desc = 'dump messages' })
--------------------------------------------------------------------------------
-- Commands
--------------------------------------------------------------------------------
command('ClearRegisters', function()
  local regs =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-'
  for r in regs:gmatch('.') do
    fn.setreg(r, {})
  end
end)
--------------------------------------------------------------------------------
command('Reverse', '<line1>,<line2>g/^/m<line1>-1', {
  range = '%',
  bar = true,
})
--------------------------------------------------------------------------------
-- see: https://github.com/yutkat/convert-git-url.nvim
command('ConvertGitUrl', function()
  local save_pos = fn.getpos('.')
  local cur = fn.expand('<cWORD>')
  if string.match(cur, '^git@') then
    vim.cmd([[s#git@\(.\{-\).com:#https://\1.com/#]])
  elseif string.match(cur, '^http') then
    vim.cmd([[s#https://\(.\{-\).com/#git@\1.com:#]])
  end
  fn.setpos('.', save_pos)
end, { force = true })
map('n', '<leader>gu', '<Cmd>ConvertGitUrl<CR>', { desc = 'convert git url' })
--------------------------------------------------------------------------------
-- 70/30 split for split windows
map('n', '<leader>wr', function()
  vim.ui.input({ prompt = 'Enter win size: ', default = '120' }, function(input)
    if not input or input == '' then return end
    vim.cmd('vertical resize ' .. input)
  end)
end, { desc = 'increase vertical spacing' })
--------------------------------------------------------------------------------
-- Redirect messages to a file
-- @see: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/commands.lua#L50
ar.command('Redir', function()
  vim.cmd('redir => msg_output | silent messages | redir END')
  local output = fn.split(vim.g.msg_output, '\n')
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, output)
  ar.open_buf_centered_popup(buf)
end)
ar.add_to_menu('command_palette', { ['Open Messages'] = 'Redir' })
--------------------------------------------------------------------------------
-- Reorder numbered list
-- Works for the list where the numbers are followed by ". ", "). ", or "]. "
-- '<,'>s/\d\+\(\(\.\|)\.\|\]\.\)\s\)\@=/\=line('.')-line("'<")+1/
--                             ^
--                             |
--                             ----- add more cases here
--                             E.g., "\|>\." for the list like "1>. foobar"
-- @see: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/commands.lua#L85
ar.command(
  'ReorderList',
  [['<,'>s/\d\+\(\(\.\|)\.\|\]\.\)\s\)\@=/\=line('.')-line("'<")+1/]],
  { range = true }
)
--------------------------------------------------------------------------------
-- Share Code
---> Share the file or a range of lines over https://0x0.st .
function ar.null_pointer()
  local from = api.nvim_buf_get_mark(0, '<')[1]
  local to = api.nvim_buf_get_mark(0, '>')[1]
  local file = fn.tempname()
  vim.cmd(
    ':silent! ' .. (from == to and '' or from .. ',' .. to) .. 'w ' .. file
  )

  fn.jobstart({ 'curl', '-sF', 'file=@' .. file .. '', 'https://0x0.st' }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      fn.setreg('+', data[1])
      vim.notify('Copied ' .. data[1] .. ' to clipboard!')
    end,
    on_stderr = function(_, data)
      if data then print(table.concat(data)) end
    end,
  })
end
nnoremap('<localleader>up', ar.null_pointer, { desc = 'share code url' })
xnoremap(
  '<localleader>pp',
  ':lua ar.null_pointer()<CR>gv<Esc>',
  { desc = 'share code url' }
)
command('NullPointer', ar.null_pointer)
ar.add_to_menu('command_palette', { ['Share Code URL'] = 'NullPointer' })
--------------------------------------------------------------------------------
-- Abbreviations
--------------------------------------------------------------------------------
vim.cmd("iabbrev <expr> ,d strftime('%Y-%m-%d')")
vim.cmd("iabbrev <expr> ,t strftime('%Y-%m-%dT%TZ')")
vim.cmd("inoreabbrev <expr> ,u system('uuidgen')->trim()->tolower()")
vim.cmd('inoreabbrev fucntion function')
vim.cmd('inoreabbrev cosnt const')
vim.cmd('cnoreabbrev W! w!')
vim.cmd('cnoreabbrev Q! q!')
vim.cmd('cnoreabbrev Wq wq')
vim.cmd('cnoreabbrev wQ wq')
vim.cmd('cnoreabbrev WQ wq')
vim.cmd('cnoreabbrev W w')
vim.cmd('cnoreabbrev Q q')
