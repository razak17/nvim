if not rvim then return end

local o, opt, fn = vim.o, vim.opt, vim.fn
----------------------------------------------------------------------------------------------------
-- Neovim Directories {{{1
----------------------------------------------------------------------------------------------------
o.udir = rvim.get_cache_dir() .. '/undodir'
o.directory = rvim.get_cache_dir() .. '/swap'
o.viewdir = rvim.get_cache_dir() .. '/view'
----------------------------------------------------------------------------------------------------
-- Message output on vim actions {{{1
----------------------------------------------------------------------------------------------------
opt.shortmess = {
  t = true, -- truncate file messages at start
  A = true, -- ignore annoying swap file messages
  o = true, -- file-read message overwrites previous
  O = true, -- file-read message overwrites previous
  T = true, -- truncate non-file messages in middle
  f = true, -- (file x of x) instead of just (x of x
  F = true, -- Don't give file info when editing a file, NOTE: this breaks autocommand messages
  s = true,
  c = true,
  W = true, -- Don't show [w] or written when writing
}
----------------------------------------------------------------------------------------------------
-- Timings {{{1
----------------------------------------------------------------------------------------------------
o.updatetime = 300
o.timeout = true
o.timeoutlen = 500
o.ttimeoutlen = 10
----------------------------------------------------------------------------------------------------
-- Window splitting and buffers {{{1
----------------------------------------------------------------------------------------------------
if o.splitkeep then o.splitkeep = 'screen' end
o.splitbelow = true
o.splitright = true
o.eadirection = 'hor'
-- exclude usetab rvim we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
o.switchbuf = 'useopen,uselast'
opt.fillchars = {
  fold = ' ',
  eob = ' ', -- suppress ~ at EndOfBuffer
  diff = '╱', -- alternatives = ⣿ ░ ─
  msgsep = ' ', -- alternatives: ‾ ─
  foldopen = '▾', -- alternatives: 
  foldsep = '│',
  foldclose = '▸', -- alternatives: 
}
----------------------------------------------------------------------------------------------------
-- Diff {{{1
----------------------------------------------------------------------------------------------------
-- Use in vertical diff mode, blank lines to keep sides aligned, Ignore whitespace changes
opt.diffopt = opt.diffopt
  + {
    'vertical',
    'iwhite',
    'hiddenoff',
    'foldcolumn:0',
    'context:4',
    'algorithm:histogram',
    'indent-heuristic',
  }
if rvim.nightly() then opt.diffopt:append({ 'linematch:60' }) end
----------------------------------------------------------------------------------------------------
-- Format Options {{{1
----------------------------------------------------------------------------------------------------
opt.formatoptions = {
  ['1'] = true,
  ['2'] = true, -- Use indent from 2nd line of a paragraph
  q = true, -- continue comments with gq"
  n = true, -- Recognize numbered lists
  t = false, -- autowrap lines using text width value
  j = true, -- remove a comment leader when joining lines.
  -- Only break if the line was not longer than 'textwidth' when the insert
  -- started and only at a white character that has been entered during the
  -- current insert command.
  l = true,
  v = true,
}
----------------------------------------------------------------------------------------------------
-- Folds {{{1
----------------------------------------------------------------------------------------------------
o.foldlevelstart = 10
----------------------------------------------------------------------------------------------------
-- Grepprg {{{1
----------------------------------------------------------------------------------------------------
-- Use faster grep alternatives if possible
if rvim.executable('rg') then
  vim.o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
  vim.o.grepprg = [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
  goto continue
end
if rvim.executable('ag') then
  vim.o.grepprg = [[ag --nogroup --nocolor --vimgrep]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
end
::continue::
----------------------------------------------------------------------------------------------------
-- Wild and file globbing stuff in command mode {{{1
----------------------------------------------------------------------------------------------------
o.wildcharm = ('\t'):byte()
o.wildmode = 'list:full' -- Shows a menu bar as opposed to an enormous list
o.wildignorecase = true -- Ignore case when completing file names and directories
-- Binary
opt.wildignore = {
  '*.aux',
  '*.out',
  '*.toc',
  '*.o',
  '*.obj',
  '*.dll',
  '*.jar',
  '*.pyc',
  '*.rbc',
  '*.class',
  '*.gif',
  '*.ico',
  '*.jpg',
  '*.jpeg',
  '*.png',
  '*.avi',
  '*.wav',
  -- Temp/System
  '*.*~',
  '*~ ',
  '*.swp',
  '.lock',
  '.DS_Store',
  'tags.lock',
}
opt.wildoptions = { 'pum', 'fuzzy' }
-- o.pumblend = 3 -- Make popup window translucent, NOTE: causes codicons to be rendered funny
----------------------------------------------------------------------------------------------------
-- Display {{{1
----------------------------------------------------------------------------------------------------
o.showcmd = false
o.showfulltag = true -- Show tag and tidy search in completion
o.sidescrolloff = 5
o.scrolloff = 7
-- o.concealcursor = 'niv'
o.conceallevel = 2
o.breakindentopt = 'sbr'
o.linebreak = true -- lines wrap at words rather than random characters
o.synmaxcol = 1024 -- don't syntax highlight long lines
o.signcolumn = 'yes:1'
o.ruler = false
o.cmdheight = 1
o.showbreak = [[↪ ]] -- Options include -> '…', '↳ ', '→','↪ '
----------------------------------------------------------------------------------------------------
-- List chars {{{1
----------------------------------------------------------------------------------------------------
o.list = true -- invisible chars
opt.listchars = {
  eol = nil,
  nbsp = '+',
  tab = '  ', -- Alternatives: '▷▷',
  extends = '…', -- Alternatives: … » ›
  precedes = '░', -- Alternatives: … « ‹
  trail = '·', -- BULLET (U+2022, UTF-8: E2 80 A2) •
}
----------------------------------------------------------------------------------------------------
-- Indentation
----------------------------------------------------------------------------------------------------
o.wrap = false
o.wrapmargin = 2
o.textwidth = 0
o.autoindent = true
o.shiftround = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = -1
o.cindent = true -- Increase indent on line after opening brace
o.smartindent = true
----------------------------------------------------------------------------------------------------
-- vim.o.debug = "msg"
o.gdefault = true
o.pumheight = 15
o.confirm = true -- make vim prompt me to save before doing destructive things
opt.completeopt = { 'menuone', 'noselect' }
o.hlsearch = true
o.autowriteall = true -- automatically :write before running commands and changing files
opt.clipboard = { 'unnamedplus' }
o.laststatus = 3
o.showtabline = 0
o.termguicolors = true
opt.diffopt:append('linematch:50')
----------------------------------------------------------------------------------------------------
-- Emoji {{{1
----------------------------------------------------------------------------------------------------
-- emoji is true by default but makes (n)vim treat all emoji rvim double width
-- which breaks rendering so we turn this off.
-- CREDIT: https://www.youtube.com/watch?v=F91VWOelFNE
o.emoji = false
----------------------------------------------------------------------------------------------------
-- Cursor {{{1
----------------------------------------------------------------------------------------------------
-- NOTE: Using a block cursor in all modes causes ghost text in dressing prompt
-- opt.guicursor = ""
----------------------------------------------------------------------------------------------------
-- Title {{{1
----------------------------------------------------------------------------------------------------
function rvim.modified_icon() return vim.bo.modified and rvim.ui.codicons.ui.filled_circle or '' end
-- titlestring = ' ❐ %{fnamemodify(getcwd(), ":t")} %m'
o.titlestring = '%<%F%=%l/%L - nvim'
o.titleold = fn.fnamemodify(vim.loop.os_getenv('SHELL'), ':t')
o.title = true
o.titlelen = 70
----------------------------------------------------------------------------------------------------
-- Utilities {{{1
----------------------------------------------------------------------------------------------------
o.showmode = false
-- NOTE: Don't remember
-- * help files since that will error if they are from a lazy loaded plugin
-- * folds since they are created dynamically and might be missing on startup
opt.sessionoptions = {
  'globals',
  'buffers',
  'curdir',
  'winpos',
  'tabpages',
}
-- What to save for views and sessions:
opt.viewoptions = { 'cursor', 'folds' } -- save/restore just these (with `:{mk,load}view`)
o.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode
-- opt.shadafile = join_paths(rvim.get_cache_dir(), 'shada', 'rvim.shada')
----------------------------------------------------------------------------------------------------
-- Jumplist
----------------------------------------------------------------------------------------------------
opt.jumpoptions = { 'stack' } -- make the jumplist behave like a browser stack
----------------------------------------------------------------------------------------------------
-- BACKUP AND SWAPS {{{
----------------------------------------------------------------------------------------------------
o.backup = false
o.undofile = true
o.undolevels = 10000
o.swapfile = false
--}}}
----------------------------------------------------------------------------------------------------
-- Match and search {{{1
----------------------------------------------------------------------------------------------------
o.ignorecase = true
o.smartcase = true
o.wrapscan = true -- Searches wrap around the end of the file
o.scrolloff = 9
o.sidescrolloff = 10
o.sidescroll = 1
o.infercase = true
o.incsearch = true
o.showmatch = true
o.matchtime = 1
----------------------------------------------------------------------------------------------------
-- Spelling {{{1
----------------------------------------------------------------------------------------------------
opt.spellsuggest:prepend({ 12 })
opt.spelloptions:append({ 'camel', 'noplainbuffer' })
opt.spellcapcheck = '' -- don't check for capital letters at start of sentence
opt.fileformats = { 'unix', 'mac', 'dos' }
opt.spellfile = join_paths(rvim.get_config_dir(), 'spell', 'en.utf-8.add')
----------------------------------------------------------------------------------------------------
-- Mouse {{{1
----------------------------------------------------------------------------------------------------
o.mousefocus = true
o.mousemoveevent = true
opt.mousescroll = { 'ver:1', 'hor:6' }
----------------------------------------------------------------------------------------------------
-- these only read ".vim" files
o.secure = true -- Disable autocmd etc for project local vimrc files.
o.exrc = false -- Allow project local vimrc files example .nvimrc see :h exrc
----------------------------------------------------------------------------------------------------
-- Git editor
----------------------------------------------------------------------------------------------------
if rvim.executable('nvr') then
  vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
  vim.env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
end