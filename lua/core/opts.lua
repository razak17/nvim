local vim = vim

local function set(key, value) vim.opt[key] = value end

vim.g.vimsyn_embed = "lPr" -- allow embedded syntax highlighting for lua,python and ruby

-- vim.o.quickfixtextfunc = "{i -> v:lua.core.qftf(i)}"

-- Neovim Directories
set('udir', core.sets.udir)
set('directory', core.sets.directory)
set('viewdir', core.sets.viewdir)
set('backupskip',
  '/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim')

-- Timing
set('timeout', true)
set('ttimeout', true)
set('timeoutlen', core.sets.timeoutlen)
set('ttimeoutlen', 10)
set('updatetime', 100)
set('redrawtime', 1500)

-- Folds
set('foldmethod', 'expr')
set('foldenable', core.sets.foldenable)
set('foldlevelstart', 10)
set('foldtext', core.sets.foldtext)

-- Tabs and Indents
set('breakindentopt', 'shift:2,min:20')
set('cindent', true) -- Increase indent on line after opening brace
set('smarttab', true) -- Tab insert blanks according to 'shiftwidth'
set('autoindent', true) -- Use same indenting on new lines
set('shiftround', true) -- Round indent to multiple of 'shiftwidth'
set('tabstop', core.sets.tabstop)
set('shiftwidth', core.sets.shiftwidth)
set('textwidth', core.sets.textwidth)
set('softtabstop', -1)
set('expandtab', true)
set('smartindent', true)

-- Editor UI Appearance
set('laststatus', core.sets.laststatus)
set('showtabline', core.sets.showtabline)
set('showmode', false)
set('showbreak', [[↪ ]])
set('background', 'dark')
set('cursorcolumn', false)
set('termguicolors', true)
set('guicursor', 'n-v-c-sm:block,i-ci-ve:block,r-cr-o:block')
set('sidescrolloff', 5)
set('scrolloff', core.sets.scrolloff)
set('more', false)
set('title', true)
set('titlelen', 70)
set('titlestring', "%<%F%=%l/%L - nvim")
set('titleold', '%{fnamemodify(getcwd(), ":t")}')
set('pumheight', 15)
set('pumblend', 10)
set('cmdheight', core.sets.cmdheight)
set('cmdwinheight', 5)
set('winblend', 10)
set('winwidth', 30)
set('winminwidth', 10)
set('helpheight', 12)
set('previewheight', 12)
set('synmaxcol', 1024)
set('display', 'lastline')
set('lazyredraw', true)
set('equalalways', false)
set('numberwidth', core.sets.numberwidth)
set('list', true)
set('number', core.sets.number)
set('signcolumn', 'yes')
set('relativenumber', core.sets.relative_number)
set('listchars', 'tab:»•,nbsp:+,trail:·,precedes:,extends:')
set('diffopt',
  'vertical,iwhite,hiddenoff,foldcolumn:0,context:4,algorithm:histogram,indent-heuristic')
set('fillchars',
  'vert:▕,fold: ,eob: ,diff:─,msgsep: ,foldopen:▾,foldsep:│,foldclose:▸,eob: ')

-- Spelling
set('spelllang', core.sets.spelllang)
vim.opt.spellsuggest:prepend{12}
set('spell', core.sets.spell)
set('spelloptions', 'camel')
set('spellcapcheck', '') -- don't check for capital letters at start of sentence
set('fileformats', {"unix", "mac", "dos"}) -- don't check for capital letters at start of sentence

-- Behavior
set('wrap', core.sets.wrap)
set('eadirection', 'hor')
set('concealcursor', 'niv')
set('conceallevel', 0)
set('report', 2)
set('history', 2000)
set('undolevels', 1000)
set('shell', core.sets.shell)
set('splitbelow', true)
set('splitright', true)
set('linebreak', true)
set('maxmempattern', 1300)
set('inccommand', 'nosplit')
set('switchbuf', 'useopen,usetab,vsplit')
set('complete', '.,w,b,k') -- No wins, buffs, tags, include scanning
set('completeopt', 'menu,menuone,noselect,noinsert')
set('iskeyword', '@,48-57,_,192-255,-,#') -- Treat dash separated words as a word text object'
set('breakat', [[\ \	;:,!?]]) -- Long lines break chars
set('startofline', false) -- Cursor in same column for few commands
set('whichwrap', 'h,l,<,>,[,],~') -- Move to following line on certain keys
set('backspace', 'indent,eol,start') -- Intuitive backspacing in insert mode
set('showfulltag', true) -- Show tag and tidy search in completion
set('joinspaces', false) -- Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
set('jumpoptions', 'stack') -- list of words that change the behavior of the jumplist
set('virtualedit', 'block') -- list of words that change the behavior of the jumplist

-- Searching
set('grepprg',
  [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]])
set('grepformat', '%f:%l:%c:%m')
set('smartcase', core.sets.smartcase)
set('ignorecase', core.sets.ignorecase)
set('infercase', true)
set('incsearch', true)
set('hlsearch', core.sets.hlsearch)
set('wrapscan', true)
set('showmatch', true)
set('matchpairs', '(:),{:},[:]')
set('matchtime', 1)

-- Wildmenu
set('wildcharm',
  vim.fn.char2nr(vim.api.nvim_replace_termcodes([[<C-Z>]], true, true, true)))
set('wildignore',
  '*.so,.git,.hg,.svn,.stversions,*.pyc,*.spl,*.o,*.out,*~,%*,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**,*/.sass-cache/*,application/vendor/**,**/vendor/ckeditor/**,media/vendor/**,__pycache__,*.egg-info')
set('wildmode', 'longest,full')
set('wildoptions', 'pum')
set('wildignorecase', true)

-- What to save for views and sessions:
set('shada', "!,'300,<50,@100,s10,h")
set('viewoptions', 'cursor,folds')
set('sessionoptions', 'curdir,help,tabpages,winsize')
