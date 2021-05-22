local vim = vim
local G = require 'core.global'
local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then
    scopes['o'][key] = value
  end
end

-- Neovim Directories
opt('o', 'udir', G.cache_dir .. 'undodir')
opt('o', 'directory', G.cache_dir .. 'swap')
opt('o', 'backupdir', G.cache_dir .. 'backup')
opt('o', 'viewdir', G.cache_dir .. 'view')
opt('o', 'backupskip',
    '/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim')

-- Timing
opt('o', 'timeout', true)
opt('o', 'ttimeout', true)
opt('o', 'timeoutlen', 500)
opt('o', 'ttimeoutlen', 10)
opt('o', 'updatetime', 100)
opt('o', 'redrawtime', 1500)

-- Folds
opt('w', 'foldcolumn', '0')
opt('w', 'foldenable', true)
opt('o', 'foldlevelstart', 99)
opt('o', 'foldopen', 'hor,mark,percent,quickfix,search,tag,undo')

-- Editor UI Appearance
opt('o', 't_Co', '256')
opt('o', 'ruler', true)
opt('o', 'laststatus', 2)
opt('o', 'showcmd', false)
opt('o', 'showtabline', 2)
opt('o', 'showmode', false)
opt('o', 'showbreak', '↳  ')
opt('o', 'syntax', 'enable')
opt('o', 'encoding', 'utf-8')
opt('o', 'background', 'dark')
opt('w', 'colorcolumn', '+1')
opt('w', 'cursorline', false)
opt('o', 'cursorcolumn', false)
opt('o', 'termguicolors', true)
opt('o', 'shortmess', 'aoOTIcF')
opt('o', 'guicursor', 'n-v-c-sm:block,i-ci-ve:block,r-cr-o:block')
opt('o', 'sidescrolloff', 5)
opt('o', 'scrolloff', 2)
opt('o', 'pumheight', 15)
opt('o', 'pumblend', 10)
opt('o', 'cmdheight', 2)
opt('o', 'cmdwinheight', 5)
opt('o', 'winblend', 10)
opt('o', 'winwidth', 30)
opt('o', 'winminwidth', 10)
opt('o', 'hidden', true)
opt('o', 'helpheight', 12)
opt('o', 'previewheight', 12)
opt('o', 'synmaxcol', 2500)
opt('o', 'display', 'lastline')
opt('o', 'lazyredraw', true)
opt('o', 'equalalways', false)
opt('o', 'numberwidth', 4)
opt('b', 'fileencoding', 'utf-8')
opt('b', 'formatoptions', '1jcroql')
opt('w', 'list', true)
opt('w', 'number', true)
opt('w', 'signcolumn', 'yes')
opt('w', 'relativenumber', true)
opt('w', 'listchars', 'tab:»·,nbsp:+,trail:·,precedes:,extends:')

-- Behavior
opt('b', 'swapfile', false)
opt('b', 'undofile', true)
opt('w', 'concealcursor', 'niv')
opt('w', 'conceallevel', 0)
opt('w', 'wrap', false)
opt('o', 'report', 2)
opt('o', 'backup', false)
opt('o', 'history', 2000)
opt('o', 'writebackup', false)
opt('o', 'undolevels', 1000)
opt('o', 'shell', '/bin/zsh')
opt('o', 'errorbells', false)
opt('o', 'splitbelow', true)
opt('o', 'splitright', true)
opt('o', 'mouse', 'a')
opt('o', 'linebreak', true)
opt('o', 'maxmempattern', 1300)
opt('o', 'inccommand', 'nosplit')
opt('o', 'switchbuf', 'useopen,usetab,vsplit')
opt('o', 'diffopt', 'filler,iwhite,internal,algorithm:patience')
opt('o', 'completeopt', 'menu,menuone,noselect,noinsert')
opt('o', 'complete', '.,w,b,k') -- No wins, buffs, tags, include scanning
opt('o', 'iskeyword', '@,48-57,_,192-255,-,#') -- Treat dash separated words as a word text object'
opt('o', 'breakat', [[\ \	;:,!?]]) -- Long lines break chars
opt('o', 'startofline', false) -- Cursor in same column for few commands
opt('o', 'whichwrap', 'h,l,<,>,[,],~') -- Move to following line on certain keys
opt('o', 'backspace', 'indent,eol,start') -- Intuitive backspacing in insert mode
opt('o', 'showfulltag', true) -- Show tag and tidy search in completion
opt('o', 'joinspaces', false) -- Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
opt('o', 'jumpoptions', 'stack') -- list of words that change the behavior of the jumplist
opt('o', 'virtualedit', 'block') -- list of words that change the behavior of the jumplist
opt('o', 'magic', true) -- list of words that change the behavior of the jumplist

-- Tabs and Indents
opt('o', 'breakindentopt', 'shift:2,min:20')
opt('o', 'cindent', true) -- Increase indent on line after opening brace
opt('o', 'smarttab', true) -- Tab insert blanks according to 'shiftwidth'
opt('o', 'autoindent', true) -- Use same indenting on new lines
opt('o', 'shiftround', true) -- Round indent to multiple of 'shiftwidth'
opt('b', 'tabstop', 2) -- The number of spaces a tab is
opt('b', 'shiftwidth', 2) -- Number of spaces to use in auto(indent)
opt('b', 'textwidth', 80) -- Text width maximum chars before wrapping
opt('b', 'softtabstop', -1) -- Number of spaces to use in auto(indent)
opt('b', 'expandtab', true) -- Expand tabs to spaces.
opt('b', 'smartindent', true) -- Insert indents automatically

-- Searching
opt('o', 'grepprg', 'rg --hidden --vimgrep --smart-case --')
opt('o', 'grepformat', '%f:%l:%c:%m')
opt('o', 'smartcase', true)
opt('o', 'ignorecase', true)
opt('o', 'infercase', true)
opt('o', 'incsearch', true)
opt('o', 'hlsearch', true)
opt('o', 'wrapscan', true)
opt('o', 'showmatch', true)
opt('o', 'matchpairs', '(:),{:},[:]')
opt('o', 'matchtime', 1)

-- Wildmenu
opt('o', 'wildmode', 'list:longest,full')
opt('o', 'wildoptions', 'tagfile')
opt('o', 'wildignorecase', true)
opt('o', 'wildmenu', false)
opt('o', 'wildignore',
    '*.so,.git,.hg,.svn,.stversions,*.pyc,*.spl,*.o,*.out,*~,%*,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**,*/.sass-cache/*,application/vendor/**,**/vendor/ckeditor/**,media/vendor/**,__pycache__,*.egg-info')

-- What to save for views and sessions:
opt('o', 'clipboard', 'unnamedplus')
opt('o', 'shada', "!,'300,<50,@100,s10,h")
opt('o', 'viewoptions', 'folds,cursor,curdir,slash,unix')
opt('o', 'sessionoptions', 'curdir,help,tabpages,winsize')
