local vim = vim
local G = require 'core.global'

local function set(key, value) vim.opt[key] = value end

vim.cmd('set iskeyword+=-')
-- vim.go.t_Co = "256"
vim.g.vimsyn_embed = "lPr" -- allow embedded syntax highlighting for lua,python and ruby

-- Neovim Directories
set('udir', G.cache_dir .. 'undodir')
set('directory', G.cache_dir .. 'swap')
set('backupdir', G.cache_dir .. 'backup')
set('viewdir', G.cache_dir .. 'view')

-- Timing
set('timeout', true)
set('ttimeout', true)
set('timeoutlen', 500)
set('ttimeoutlen', 10)
set('updatetime', 100)
set('redrawtime', 1500)

-- Editor UI Appearance
set('ruler', true)
set('laststatus', 0)
set('colorcolumn', '+1')
set('showtabline', 0)
set('cursorline', false)
set('showcmd', false)
set('showmode', false)
set('showbreak', [[↪ ]])
-- set('syntax', 'enable')
set('encoding', 'utf-8')
set('background', 'dark')
set('cursorcolumn', false)
set('termguicolors', true)
set('shortmess', 'aoOTIcF')
set('guicursor', 'n-v-c-sm:block,i-ci-ve:block,r-cr-o:block')
set('sidescrolloff', 5)
set('scrolloff', 2)
set('pumheight', 15)
set('pumblend', 10)
set('cmdheight', 2)
set('cmdwinheight', 5)
set('winblend', 10)
set('winwidth', 30)
set('winminwidth', 10)
set('hidden', true)
set('helpheight', 12)
set('previewheight', 12)
set('synmaxcol', 2500)
set('display', 'lastline')
set('lazyredraw', true)
set('equalalways', false)
set('numberwidth', 4)
set('fileencoding', 'utf-8')
set('list', true)
set('number', false)
set('signcolumn', 'yes')
-- opt('w', 'relativenumber', true)
-- opt('w', 'listchars', 'tab:»•,nbsp:+,trail:·,precedes:,extends:')
set('diffopt',
    'vertical,iwhite,hiddenoff,foldcolumn:0,context:4,algorithm:histogram,indent-heuristic')
set('fillchars',
    'vert:▕,fold: ,eob: ,diff:─,msgsep: ,foldopen:▾,foldsep:│,foldclose:▸,eob: ')

-- Behavior
set('swapfile', false)
set('backup', false)
set('undofile', true)
set('wrap', false)
set('errorbells', false)
set('writebackup', false)
set('title', true)
-- vim.o.titlestring = "%(%F%)%a\ -\ VIM%(\ %M%)"

set('eadirection', 'hor')
set('concealcursor', 'niv')
set('conceallevel', 0)
set('report', 2)
set('history', 2000)
set('undolevels', 1000)
set('shell', '/bin/zsh')
set('splitbelow', true)
set('splitright', true)
set('mouse', 'a')
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
set('magic', true) -- list of words that change the behavior of the jumplist

-- Tabs and Indents
set('breakindentopt', 'shift:2,min:20')
-- opt('o', 'cindent', true) -- Increase indent on line after opening brace
set('smarttab', true) -- Tab insert blanks according to 'shiftwidth'
set('autoindent', true) -- Use same indenting on new lines
-- opt('o', 'shiftround', true) -- Round indent to multiple of 'shiftwidth'
set('tabstop', 2) -- The number of spaces a tab is
set('shiftwidth', 2) -- Number of spaces to use in auto(indent)
set('textwidth', 104) -- Text width maximum chars before wrapping
set('softtabstop', -1) -- Number of spaces to use in auto(indent)
set('expandtab', true) -- Expand tabs to spaces.
set('smartindent', true) -- Insert indents automatically

-- Searching
set('grepprg',
    [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]])
set('grepformat', '%f:%l:%c:%m')
set('smartcase', true)
set('ignorecase', true)
set('infercase', true)
set('incsearch', true)
set('hlsearch', true)
set('wrapscan', true)
set('showmatch', true)
set('matchpairs', '(:),{:},[:]')
set('matchtime', 1)

-- Wildmenu
set('wildignore',
    '*.so,.git,.hg,.svn,.stversions,*.pyc,*.spl,*.o,*.out,*~,%*,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**,*/.sass-cache/*,application/vendor/**,**/vendor/ckeditor/**,media/vendor/**,__pycache__,*.egg-info')
set('wildmode', 'longest,full')
set('wildoptions', 'pum')
set('wildignorecase', true)

-- What to save for views and sessions:
set('clipboard', 'unnamedplus')
set('autoread', true)
set('autowrite', true)
set('shada', "!,'300,<50,@100,s10,h")
set('viewoptions', 'cursor,folds')
set('sessionoptions', 'curdir,help,tabpages,winsize')
vim.g.vimsyn_embed = "lPr" -- allow embedded syntax highlighting for lua,python and ruby
