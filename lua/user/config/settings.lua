local opt, fn = vim.opt, vim.fn
-----------------------------------------------------------------------------//
-- Neovim Directories {{{1
-----------------------------------------------------------------------------//
opt.udir = rvim.get_cache_dir() .. '/undodir'
opt.directory = rvim.get_cache_dir() .. '/swap'
opt.viewdir = rvim.get_cache_dir() .. '/view'
-----------------------------------------------------------------------------//
-- Message output on vim actions {{{1
-----------------------------------------------------------------------------//
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
-----------------------------------------------------------------------------//
-- Timings {{{1
-----------------------------------------------------------------------------//
opt.updatetime = 300
opt.timeout = true
opt.timeoutlen = 500
opt.ttimeoutlen = 10
-----------------------------------------------------------------------------//
-- Window splitting and buffers {{{1
-----------------------------------------------------------------------------//
opt.splitbelow = true
opt.splitright = true
opt.eadirection = 'hor'
-- exclude usetab rvim we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
vim.o.switchbuf = 'useopen,uselast'
opt.fillchars = {
  fold = ' ',
  eob = ' ', -- suppress ~ at EndOfBuffer
  diff = '╱', -- alternatives = ⣿ ░ ─
  msgsep = ' ', -- alternatives: ‾ ─
  foldopen = '▾',
  foldsep = '│',
  foldclose = '▸',
}
-----------------------------------------------------------------------------//
-- Diff {{{1
-----------------------------------------------------------------------------//
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
-----------------------------------------------------------------------------//
-- Format Options {{{1
-----------------------------------------------------------------------------//
opt.formatoptions = {
  ['1'] = true,
  ['2'] = true, -- Use indent from 2nd line of a paragraph
  q = true, -- continue comments with gq"
  c = true, -- Auto-wrap comments using textwidth
  r = true, -- Continue comments when pressing Enter
  n = true, -- Recognize numbered lists
  t = false, -- autowrap lines using text width value
  j = true, -- remove a comment leader when joining lines.
  -- Only break if the line was not longer than 'textwidth' when the insert
  -- started and only at a white character that has been entered during the
  -- current insert command.
  l = true,
  v = true,
}
-----------------------------------------------------------------------------//
-- Folds {{{1
-----------------------------------------------------------------------------//
opt.foldenable = true
opt.foldlevelstart = 2
if not rvim.plugin_installed('nvim-ufo') then
  opt.foldexpr = 'nvim_treesitter#foldexpr()'
  opt.foldmethod = 'expr'
end
-- opt.foldtext = "v:lua.folds()"
-----------------------------------------------------------------------------//
-- Grepprg {{{1
-----------------------------------------------------------------------------//
-- Use faster grep alternatives if possible
if rvim.executable('rg') then
  vim.o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
  vim.o.grepprg = [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
elseif rvim.executable('ag') then
  vim.o.grepprg = [[ag --nogroup --nocolor --vimgrep]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
end
-----------------------------------------------------------------------------//
-- Wild and file globbing stuff in command mode {{{1
-----------------------------------------------------------------------------//
opt.wildcharm = fn.char2nr(rvim.replace_termcodes([[<Tab>]]))
opt.wildmode = 'longest:full,full' -- Shows a menu bar rvim opposed to an enormous list
opt.wildignorecase = true -- Ignore case when completing file names and directories
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
opt.wildoptions = 'pum'
opt.pumblend = 3 -- Make popup window translucent
-----------------------------------------------------------------------------//
-- Display {{{1
-----------------------------------------------------------------------------//
opt.showcmd = false
opt.showfulltag = true -- Show tag and tidy search in completion
opt.sidescrolloff = 5
opt.scrolloff = 7
opt.concealcursor = 'niv'
opt.conceallevel = 2
opt.breakindentopt = 'sbr'
opt.linebreak = true -- lines wrap at words rather than random characters
opt.synmaxcol = 1024 -- don't syntax highlight long lines
opt.signcolumn = 'auto:2-5'
opt.ruler = false
opt.cmdheight = 1
opt.showbreak = [[↪ ]] -- Options include -> '…', '↳ ', '→','↪ '
--- This is used to handle markdown code blocks where the language might
--- be set to a value that isn't equivalent to a vim filetype
vim.g.markdown_fenced_languages = {
  'js=javascript',
  'ts=typescript',
  'shell=sh',
  'bash=sh',
  'console=sh',
}
-----------------------------------------------------------------------------//
-- List chars {{{1
-----------------------------------------------------------------------------//
opt.list = true -- invisible chars
opt.listchars = {
  eol = nil,
  nbsp = '+',
  tab = '  ', -- Alternatives: '▷▷',
  extends = '', -- Alternatives: … » ›
  precedes = '', -- Alternatives: … « ‹
  trail = '·', -- BULLET (U+2022, UTF-8: E2 80 A2) •
}
-----------------------------------------------------------------------------//
-- Indentation
-----------------------------------------------------------------------------//
opt.wrap = false
opt.wrapmargin = 2
opt.textwidth = 0
opt.autoindent = true
opt.shiftround = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = -1
opt.cindent = true -- Increase indent on line after opening brace
opt.smartindent = true
-----------------------------------------------------------------------------//
-- vim.o.debug = "msg"
opt.gdefault = true
opt.pumheight = 15
opt.confirm = true -- make vim prompt me to save before doing destructive things
opt.completeopt = { 'menuone', 'noselect' }
opt.hlsearch = true
opt.autowriteall = true -- automatically :write before running commands and changing files
opt.clipboard = { 'unnamedplus' }
opt.laststatus = 3
opt.termguicolors = true
-- opt.guifont = 'CartographCF Nerd Font Mono:h14,codicon'
-----------------------------------------------------------------------------//
-- Emoji {{{1
-----------------------------------------------------------------------------//
-- emoji is true by default but makes (n)vim treat all emoji rvim double width
-- which breaks rendering so we turn this off.
-- CREDIT: https://www.youtube.com/watch?v=F91VWOelFNE
opt.emoji = false
-----------------------------------------------------------------------------//
-- Cursor {{{1
-----------------------------------------------------------------------------//
-- This is from the help docs, it enables mode shapes, "Cursor" highlight, and blinking
opt.guicursor = {
  [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]],
  [[a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor]],
  [[sm:block-blinkwait175-blinkoff150-blinkon175]],
}
-----------------------------------------------------------------------------//
-- Title {{{1
-----------------------------------------------------------------------------//
function rvim.modified_icon() return vim.bo.modified and rvim.style.icons.misc.circle or '' end
-- titlestring = ' ❐ %{fnamemodify(getcwd(), ":t")} %m'
opt.titlestring = '%<%F%=%l/%L - nvim'
opt.titleold = fn.fnamemodify(vim.loop.os_getenv('SHELL'), ':t')
opt.title = true
opt.titlelen = 70
-----------------------------------------------------------------------------//
-- Utilities {{{1
-----------------------------------------------------------------------------//
opt.showmode = false
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
opt.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode
-- opt.shadafile = join_paths(rvim.get_cache_dir(), 'shada', 'rvim.shada')
-----------------------------------------------------------------------------//
-- Jumplist
-----------------------------------------------------------------------------//
opt.jumpoptions = { 'stack' } -- make the jumplist behave like a browser stack
-------------------------------------------------------------------------------
-- BACKUP AND SWAPS {{{
-------------------------------------------------------------------------------
opt.backup = false
opt.undofile = true
opt.swapfile = false
--}}}
-----------------------------------------------------------------------------//
-- Match and search {{{1
-----------------------------------------------------------------------------//
opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true -- Searches wrap around the end of the file
opt.scrolloff = 9
opt.sidescrolloff = 10
opt.sidescroll = 1
opt.infercase = true
opt.incsearch = true
opt.showmatch = true
-- matchpairs = '(:),{:},[:]',
-- matchtime = 1,
-----------------------------------------------------------------------------//
-- Spelling {{{1
-----------------------------------------------------------------------------//
opt.spell = true
opt.spellsuggest:prepend({ 12 })
opt.spelloptions = 'camel'
opt.spellcapcheck = '' -- don't check for capital letters at start of sentence
opt.fileformats = { 'unix', 'mac', 'dos' }
opt.spelllang:append('programming')
opt.spellfile = join_paths(rvim.get_config_dir(), 'spell', 'en.utf-8.add')
-----------------------------------------------------------------------------//
-- Mouse {{{1
-----------------------------------------------------------------------------//
opt.mouse = 'a'
opt.mousefocus = true
opt.mousescroll = { 'ver:1', 'hor:6' }
-----------------------------------------------------------------------------//
-- these only read ".vim" files
opt.secure = true -- Disable autocmd etc for project local vimrc files.
opt.exrc = false -- Allow project local vimrc files example .nvimrc see :h exrc
-----------------------------------------------------------------------------//
-- Git editor
-----------------------------------------------------------------------------//
if rvim.executable('nvr') then
  vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
  vim.env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
end
-- vim:foldmethod=marker

if rvim.ui.line_wrap_cursor_movement then vim.opt.whichwrap:append('<,>,[,],h,l,~') end
if rvim.ui.transparent_window then require('user.utils').enable_transparent_mode() end
