if not ar then return end

local ui = ar.ui
local o, opt, fn = vim.o, vim.opt, vim.fn
--------------------------------------------------------------------------------
-- Neovim Directories {{{1
--------------------------------------------------------------------------------
o.udir = vim.fn.stdpath('cache') .. '/undodir'
o.viewdir = vim.fn.stdpath('cache') .. '/view'
--------------------------------------------------------------------------------
-- Message output on vim actions {{{1
--------------------------------------------------------------------------------
opt.shortmess = {
  t = true, -- truncate file messages at start
  A = true, -- ignore annoying swap file messages
  o = true, -- file-read message overwrites previous
  O = true, -- file-read message overwrites previous
  T = true, -- truncate non-file messages in middle
  F = true, -- Don't give file info when editing a file, NOTE: this breaks autocommand messages
  s = true,
  c = true,
  W = true, -- Don't show [w] or written when writing
}
--------------------------------------------------------------------------------
-- Timings {{{1
--------------------------------------------------------------------------------
o.updatetime = 250
o.timeout = true
o.timeoutlen = 500
o.ttimeoutlen = 10
--------------------------------------------------------------------------------
-- Window splitting and buffers {{{1
--------------------------------------------------------------------------------
o.splitkeep = 'screen'
o.splitbelow = true
o.splitright = true
o.eadirection = 'hor'
-- exclude usetab as we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
o.switchbuf = 'useopen,uselast'
opt.fillchars = {
  fold = ' ',
  foldopen = '▽', -- ▼ 
  foldclose = '▷', -- ▶ 
  eob = ' ', -- suppress ~ at EndOfBuffer
  diff = '╱', -- alternatives = ⣿ ░ ─
  msgsep = ' ', -- alternatives: ‾ ─
  foldsep = '│',
}
--------------------------------------------------------------------------------
-- Diff {{{1
--------------------------------------------------------------------------------
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
    'linematch:60',
  }
--------------------------------------------------------------------------------
-- Format Options {{{1
--------------------------------------------------------------------------------
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
opt.iskeyword:append('-')
--------------------------------------------------------------------------------
-- Folds {{{1
--------------------------------------------------------------------------------
o.foldenable = true
o.foldlevelstart = 99
o.foldlevel = 99
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
if not ar_config.plugin.custom.custom_fold.enable then opt.foldtext = '' end
opt.foldcolumn = '0'
opt.foldnestmax = 10
--------------------------------------------------------------------------------
-- Grepprg {{{1
--------------------------------------------------------------------------------
-- Use faster grep alternatives if possible
if ar and not ar.falsy(fn.executable('rg')) then
  vim.o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
  vim.o.grepprg =
    [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
  goto continue
elseif ar and not ar.falsy(fn.executable('ag')) then
  vim.o.grepprg = [[ag --nogroup --nocolor --vimgrep]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
end
::continue::
--------------------------------------------------------------------------------
-- Wild and file globbing stuff in command mode {{{1
--------------------------------------------------------------------------------
o.wildcharm = ('\t'):byte()
o.wildmenu = false -- Turn (on/)off the native commandline completion menu
o.wildmode = 'full' -- 'list:full' -- Shows a menu bar as opposed to an enormous list
o.wildignorecase = true -- Ignore case when completing file names and directories
opt.wildignore = {
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
  '*.swp',
  '.lock',
  '.DS_Store',
  'tags.lock',
}
opt.wildignore =
  vim.tbl_extend('force', opt.wildignore, ui.colorscheme.disabled)
opt.wildoptions = { 'pum', 'fuzzy' }
-- NOTE: causes codicons to be rendered funny in cmp window
o.pumblend = 0 -- Make popup window translucent,
--------------------------------------------------------------------------------
-- Display {{{1
--------------------------------------------------------------------------------
-- o.showcmd = false
o.showfulltag = true -- Show tag and tidy search in completion
o.sidescrolloff = 5
o.scrolloff = 7
-- o.concealcursor = 'niv'
o.conceallevel = 2
o.breakindentopt = 'sbr'
o.linebreak = true -- lines wrap at words rather than random characters
o.signcolumn = 'yes:1'
o.ruler = false
o.cmdheight = 1
o.showbreak = [[↪ ]] -- Options include -> '…', '↳ ', '→', '↴'
--------------------------------------------------------------------------------
-- List chars {{{1
--------------------------------------------------------------------------------
o.list = true -- invisible chars
opt.listchars = {
  eol = nil,
  nbsp = '+',
  tab = '  ', -- Alternatives: '▷▷',
  extends = '…', -- Alternatives: … » ›
  precedes = '░', -- Alternatives: … « ‹
  trail = '·', -- BULLET (U+2022, UTF-8: E2 80 A2) •
}
--------------------------------------------------------------------------------
-- Indentation
--------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------
o.pumheight = 15
o.confirm = true -- make vim prompt me to save before doing destructive things
opt.completeopt = { 'menuone', 'noselect' }
if ar.has('nvim-0.11') then
  opt.completeopt:append('fuzzy') -- Use fuzzy matching for built-in completion
end
o.hlsearch = true
o.autowriteall = true -- automatically :write before running commands and changing files
opt.clipboard = { 'unnamedplus' }
o.laststatus = 3
o.showtabline = 0
o.termguicolors = true
opt.diffopt:append('linematch:50')
--------------------------------------------------------------------------------
-- Emoji {{{1
--------------------------------------------------------------------------------
-- emoji is true by default but makes (n)vim treat all emoji as double width
-- which breaks rendering so we turn this off.
-- CREDIT: https://www.youtube.com/watch?v=F91VWOelFNE
o.emoji = false
--------------------------------------------------------------------------------
-- Cursor {{{1
--------------------------------------------------------------------------------
-- NOTE: Using a block cursor in all modes causes ghost text in dressing prompt
-- opt.guicursor = ""
opt.cursorlineopt = { 'both' }
--------------------------------------------------------------------------------
-- Title {{{1
--------------------------------------------------------------------------------
function ar.modified_icon()
  return vim.bo.modified and ui.codicons.misc.circle or ''
end
-- titlestring = ' ❐ %{fnamemodify(getcwd(), ":t")} %m'
o.titlestring = '%<%F%=%l/%L - nvim'
-- o.titleold = fn.fnamemodify(vim.uv.os_getenv('SHELL'), ':t')
o.title = true
o.titlelen = 70
--------------------------------------------------------------------------------
-- Utilities {{{1
--------------------------------------------------------------------------------
o.showmode = false
-- NOTE: Don't remember
-- * help files since that will error if they are from a lazy loaded plugin
-- * folds since they are created dynamically and might be missing on startup
opt.sessionoptions = {
  'globals',
  'buffers',
  'curdir',
  'winpos',
  'winsize',
  'help',
  'folds',
  'tabpages',
  'terminal',
}
-- What to save for views and sessions:
opt.viewoptions = { 'cursor', 'folds' } -- save/restore just these (with `:{mk,load}view`)
o.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode
-- opt.shadafile = join_paths(vim.fn.stdpath('cache'), 'shada', 'as.shada')
--------------------------------------------------------------------------------
-- Jumplist
--------------------------------------------------------------------------------
opt.jumpoptions = { 'stack' } -- make the jumplist behave like a browser stack
--------------------------------------------------------------------------------
-- BACKUP AND SWAPS {{{
--------------------------------------------------------------------------------
o.backup = false
o.undofile = true
o.undolevels = 10000
o.swapfile = false
--}}}
--------------------------------------------------------------------------------
-- Match and search {{{1
--------------------------------------------------------------------------------
o.ignorecase = true
o.smartcase = true
o.wrapscan = true -- Searches wrap around the end of the file
o.scrolloff = 9
o.sidescrolloff = 10
o.sidescroll = 1
o.infercase = true
o.incsearch = true
o.inccommand = 'split'
o.showmatch = true
o.matchtime = 1
--------------------------------------------------------------------------------
-- Spelling {{{1
--------------------------------------------------------------------------------
opt.spellsuggest:prepend({ 12 })
opt.spelloptions:append({ 'camel', 'noplainbuffer' })
opt.spellcapcheck = '' -- don't check for capital letters at start of sentence
-- https://vi.stackexchange.com/questions/15051/how-can-i-use-multiple-spell-files-at-the-same-time
---@diagnostic disable-next-line: assign-type-mismatch
opt.spellfile = join_paths(vim.fn.stdpath('config'), 'spell', 'en.utf-8.add')
--------------------------------------------------------------------------------
-- Mouse {{{1
--------------------------------------------------------------------------------
o.mousefocus = true
o.mousemoveevent = true
opt.mousescroll = { 'ver:1', 'hor:6' }
--------------------------------------------------------------------------------
o.exrc = ar.has('nvim-0.9')
