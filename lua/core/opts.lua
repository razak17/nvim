local vim = vim

local function set(key, value) vim.opt[key] = value end

-- Neovim Directories
set('udir', core.sets.udir)
set('directory', core.sets.directory)
set('viewdir', core.sets.viewdir)

-- Timing
set('timeoutlen', core.sets.timeoutlen)
set('updatetime', 100)

-- Folds
set('foldmethod', 'expr')
set('foldlevelstart', 10)
set('foldtext', core.sets.foldtext)
set('foldenable', core.sets.foldenable)

-- Tabs and Indents
set('breakindentopt', 'shift:2,min:20')
set('tabstop', core.sets.tabstop)
set('shiftwidth', core.sets.shiftwidth)
set('textwidth', core.sets.textwidth)

-- Editor UI Appearance
set('sidescrolloff', 5)
set('showbreak', [[↪ ]])
set('background', 'dark')
set('laststatus', core.sets.laststatus)
set('showtabline', core.sets.showtabline)
set('colorcolumn', core.sets.colorcolumn)
set('cursorline', core.sets.cursorline)
set('scrolloff', core.sets.scrolloff)
-- set('titlestring', ' 🐬 %t %r %m')
set('titlestring', "%<%F%=%l/%L - nvim")
set('cmdheight', core.sets.cmdheight)
set('numberwidth', core.sets.numberwidth)
set('number', core.sets.number)
set('signcolumn', 'yes')
set('relativenumber', core.sets.relative_number)

-- Behavior
set('wrap', core.sets.wrap)
set('spell', core.sets.spell)
set('hidden', core.sets.hidden)
set('spelllang', core.sets.spelllang)
set('complete', '.,w,b,k') -- No wins, buffs, tags, include scanning
set('completeopt', 'menu,menuone,noselect,noinsert')
set('iskeyword', '@,48-57,_,192-255,-,#') -- Treat dash separated words as a word text object'
set('breakat', [[\ \	;:,!?]]) -- Long lines break chars
set('whichwrap', 'h,l,<,>,[,],~') -- Move to following line on certain keys
set('backspace', 'indent,eol,start') -- Intuitive backspacing in insert mode
set('showfulltag', true) -- Show tag and tidy search in completion
set('joinspaces', false) -- Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
set('jumpoptions', 'stack') -- list of words that change the behavior of the jumplist
set('virtualedit', 'block') -- list of words that change the behavior of the jumplist

-- Searching
set('smartcase', core.sets.smartcase)
set('ignorecase', core.sets.ignorecase)
set('hlsearch', core.sets.hlsearch)
set('matchtime', 1)

-- What to save for views and sessions:
set('clipboard', core.sets.clipboard)
-- set('shada', "!,'300,<50,@100,s10,h")
set('shada', "")
set('viewoptions', 'cursor,folds')
set('sessionoptions', 'curdir,help,tabpages,winsize')
vim.g.vimsyn_embed = "lPr" -- allow embedded syntax highlighting for lua,python and ruby
