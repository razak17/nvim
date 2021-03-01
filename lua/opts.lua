local vim = vim
local G = require 'global'
local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then
    scopes['o'][key] = value
  end
end

opt('o', 'iskeyword', '@,48-57,_,192-255,-,#') -- Treat dash separated words as a word text object'
opt('b', 'fileencoding', 'utf-8')              -- The encoding written to file
opt('o', 'encoding', 'utf-8')                  -- The encoding displayed
opt('o', 'syntax', 'enable')                   -- Enables syntax highlighing
opt('o', 't_Co', '256')                        -- Support 256 colors
opt('o', 'mouse', 'a')                         -- Enable mouse in all previous modes
opt('o', 'report', 2)                          -- 2 for telescope --0 Automatically setting options from modelines
opt('o', 'hidden', true)                       -- hide buffers when abandoned instead of unload
opt('o', 'pumheight', 15)                      -- Pop-up menu's line height
opt('o', 'helpheight', 12)                     -- Minimum help window height
opt('o', 'previewheight', 12)                  -- Completion preview height
opt('o', 'synmaxcol', 2500)                    -- Don't syntax highlight long lines
opt("b", "formatoptions", "1jcroql")           -- Don't break lines after a one-letter word & Don't auto-wrap text

-- Neovim Directories
opt('o', 'udir', G.cache_dir .. 'undodir')
opt('o', 'writebackup', false)
opt('b', 'swapfile', false)
opt('b', 'undofile', true)
opt('o', 'backup', false)                      -- Do not make file backups
opt('o', 'undolevels', 1000)                   -- How many steps of undo history Vim should remember
opt('o', 'history', 2000)                      -- History saving

-- -- Editor UI Appearance
opt('o', 'guicursor', 'n-v-c-sm:block,i-ci-ve:block,r-cr-o:block')
opt('w', 'listchars' , 'tab:»·,nbsp:+,trail:·,precedes:,extends:')
opt('o', 'display', 'lastline')
opt('o', 'termguicolors', true)
opt('o', 'showbreak', '↳  ')
opt('o', 'pumblend', 10)                       -- transparency for the popup-menu
opt('o', 'lazyredraw', true)                   -- Don't redraw screen while running macros
opt('w', 'signcolumn', 'yes')                  -- Always show the signcolumn, otherwise it would shift the text each time
opt('w', 'colorcolumn', '80')                  -- Highlight the 80th character limit
opt('w', 'number', true)                       -- Print line number
opt('w', 'relativenumber', true)               -- Show line number relative to current line
opt('w', 'list', true)                         -- Show hidden characters
opt('w', 'cursorline', true)                   -- Highlight the current line
opt('o', 'laststatus', 2)                      -- Always display the status line
opt('o', 'background', 'dark')                 -- Tell vim what the background color looks like
opt('o', 'cmdheight', 2)                       -- More space for displaying messages
opt('o', 'showcmd', false)                     -- Don't show command in status line
opt('o', 'showmode', false)                    -- Don't show mode in cmd window
opt('o', 'shortmess', 'filnxtToOFc')           -- Don't pass messages to |ins-completion-menu|.
opt('o', 'scrolloff', 3)                       -- Keep at least 3 lines above/below
opt('o', 'sidescrolloff', 5)                   -- Keep at least 5 lines left/right
opt('o', 'numberwidth', 4)                     -- The width of the number column
opt('o', 'ruler', true)                        -- Disable default status ruler
opt('o', 'cursorcolumn', false)                -- Highlight the current column

-- Behavior
opt('o', 'diffopt', 'filler,iwhite,internal,algorithm:patience')
opt('o', 'completeopt', 'menu,menuone,noselect,noinsert')
-- opt('o', 'completeopt', 'menuone,noselect')
opt('o', 'switchbuf', 'useopen,usetab,vsplit')
opt('o', 'inccommand', 'nosplit')
opt('w', 'concealcursor', 'niv')
opt('w', 'conceallevel', 0)                    -- So that I can see `` in markdown files
opt('w', 'wrap', false)                        -- No wrap by default
opt('o', 'maxmempattern', 1300)                -- Limit memory used for pattern matching
opt('o', 'errorbells', false)                  -- Disable error bells
-- opt('o', 'linebreak', true)                    -- Break long lines at 'breakat'
-- opt('o', 'breakat', [[\ \	;:,!?]])             -- Long lines break chars
opt('o', 'startofline', false)                 -- Cursor in same column for few commands
opt('o', 'equalalways', false)                 -- Don't resize windows on split or close
opt('o', 'whichwrap', 'h,l,<,>,[,],~')         -- Move to following line on certain keys
opt('o', 'shell', '/bin/zsh')                  -- Use zsh shell in terminal
opt('o', 'splitbelow', true)                   -- Splits open bottom
opt('o', 'splitright', true)                   -- Splits open right
opt('o', 'backspace', 'indent,eol,start')      -- Intuitive backspacing in insert mode
opt('o', 'showfulltag', true)                  -- Show tag and tidy search in completion
opt('o', 'complete', '.,w,b,k')                -- No wins, buffs, tags, include scanning
opt('o', 'joinspaces', false)                  -- Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
opt('o', 'jumpoptions', 'stack')               -- list of words that change the behavior of the jumplist

-- Tabs and Indents
opt('o', 'breakindentopt', 'shift:2,min:20')
opt('o', 'showtabline', 2)                     -- Always show tabs
opt('b', 'tabstop', 2)                         -- The number of spaces a tab is
opt('b', 'softtabstop', -1)                    -- Number of spaces to use in auto(indent)
opt('b', 'expandtab', true)                    -- Expand tabs to spaces.
opt('b', 'shiftwidth', 2)                      -- Number of spaces to use in auto(indent)
opt('b', 'textwidth', 80)                      -- Text width maximum chars before wrapping
opt('b', 'smartindent', true)                  -- Insert indents automatically
opt('o', 'smarttab', true)                     -- Tab insert blanks according to 'shiftwidth'
opt('o', 'autoindent', true)                   -- Use same indenting on new lines
opt('o', 'shiftround', true)                   -- Round indent to multiple of 'shiftwidth'
opt('o', 'cindent', true)                      -- Increase indent on line after opening brace

-- Folds
opt('w', 'foldmethod', 'expr')
opt('w', 'foldcolumn', '0')
opt('o', 'foldopen', 'hor,mark,percent,quickfix,search,tag,undo')

-- Timing
opt('o', 'ttimeout', true)
opt('o', 'timeout', true)
opt('o', 'updatetime', 100)                    -- Idle time to write swap and trigger CursorHold
opt('o', 'timeoutlen', 500)                    -- Time out on mappings
opt('o', 'ttimeoutlen', 10)                    -- Time out on key codes
opt('o', 'redrawtime', 1500)                   -- Time in milliseconds for stopping display redraw

-- Searching
opt('o', 'grepprg', 'rg --hidden --vimgrep --smart-case --')
opt('o', 'grepformat', '%f:%l:%c:%m')
opt('o', 'smartcase', true)                    -- Keep case when searching with *
opt('o', 'ignorecase', true)                   -- Search ignoring case
opt('o', 'infercase', true)                    -- Adjust case in insert completion mode
opt('o', 'incsearch', true)                    -- Incremental search
opt('o', 'hlsearch', true)                     -- Highlight search results
opt('o', 'wrapscan', true)                     -- Searches wrap around the end of the file
opt('o', 'showmatch', true)                    -- Jump to matching bracket
opt('o', 'matchpairs', '(:),{:},[:],<:>')      -- Add HTML brackets to pair matching
opt('o', 'matchtime', 1)                       -- Tenths of a second to show the matching paren

-- Wildmenu
opt('o', 'wildmode', 'list:longest,full')
opt('o', 'wildoptions', 'tagfile')
opt('o', 'wildignorecase', true)               -- Ignore case in wild menu
opt('o', 'wildmenu', false)                    -- Don't show command line completion in menu
opt(
  'o',
  'wildignore',
  '*.so,.git,.hg,.svn,.stversions,*.pyc,*.spl,*.o,*.out,*~,%*,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**,*/.sass-cache/*,application/vendor/**,**/vendor/ckeditor/**,media/vendor/**,__pycache__,*.egg-info'
)

-- What to save for views and sessions:
opt('o', 'viewoptions', 'folds,cursor,curdir,slash,unix')
opt('o', 'sessionoptions', 'curdir,help,tabpages,winsize')
opt('o', 'clipboard', 'unnamedplus')

--  ShaDa/viminfo:
--   ' - Maximum number of previously edited files marks
--   < - Maximum number of lines saved for each register
--   @ - Maximum number of items in the input-line history to be
--   s - Maximum size of an item contents in KiB
--   h - Disable the effect of 'hlsearch' when loading the shada
opt('o', 'shada', "!,'300,<50,@100,s10,h")
