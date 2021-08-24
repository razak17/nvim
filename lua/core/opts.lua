local vim = vim

local M = {}

M.load_options = function()
  local opt = vim.opt
  local default_options = {
    -- Neovim Directories
    udir = vim.g.udir,
    directory = vim.g.directory,
    viewdir = vim.g.viewdir,

    -- Timing
    timeout = true,
    timeoutlen = 500,
    ttimeoutlen = 10,
    updatetime = 100,

    -- Folds
    foldmethod = "expr",
    foldenable = true,
    foldlevelstart = 10,
    foldtext = "v:lua.folds()",

    -- Splits and buffers
    splitbelow = true,
    splitright = true,
    eadirection = "hor",

    -- Display
    conceallevel = 0,
    concealcursor = "niv",
    linebreak = true,
    synmaxcol = 1024,
    signcolumn = "yes:2",
    ruler = false,
    cmdwinheight = 5,
    background = "dark",

    -- Tabs and Indents
    breakindentopt = "shift:2,min:20",
    smarttab = true, -- Tab insert blanks according to 'shiftwidth'
    tabstop = 2,
    shiftwidth = 2,
    textwidth = 100,
    softtabstop = -1,
    expandtab = true,
    cindent = true, -- Increase indent on line after opening brace
    autoindent = true, -- Use same indenting on new lines
    shiftround = true, -- Round indent to multiple of 'shiftwidth'
    smartindent = true,

    -- Title
    title = true,
    titlelen = 70,
    titlestring = "%<%F%=%l/%L - nvim",
    titleold = '%{fnamemodify(getcwd(), ":t")}',

    -- Searching
    grepprg = [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]],
    grepformat = "%f:%l:%c:%m",
    smartcase = true,
    ignorecase = true,
    infercase = true,
    incsearch = true,
    hlsearch = true,
    wrapscan = true,
    showmatch = true,
    matchpairs = "(:),{:},[:]",
    matchtime = 1,

    -- Spelling
    spelllang = "en",
    spell = false,
    spelloptions = "camel",
    spellcapcheck = "", -- don't check for capital letters at start of sentence
    fileformats = { "unix", "mac", "dos" }, -- don't check for capital letters at start of sentence

    -- Editor UI Appearance
    cmdheight = 2,
    -- colorcolumn = ""
    laststatus = 2,
    showtabline = 2,
    showmode = false,
    cursorcolumn = false,
    termguicolors = true,
    guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:block",
    sidescrolloff = 5,
    scrolloff = 7,
    winblend = 10,
    winwidth = 30,
    winminwidth = 10,
    helpheight = 12,
    previewheight = 12,
    display = "lastline",
    lazyredraw = true,
    equalalways = false,
    numberwidth = 4,
    list = true,
    fillchars = {
      vert = "▕", -- alternatives │
      fold = " ",
      eob = " ", -- suppress ~ at EndOfBuffer
      diff = "╱", -- alternatives = ⣿ ░ ─
      msgsep = "‾",
      foldopen = "▾",
      foldsep = "│",
      foldclose = "▸",
    },
    listchars = {
      eol = " ",
      nbsp = "+",
      tab = "»• ", -- Alternatives: │
      extends = "", -- Alternatives: … » ›
      precedes = "", -- Alternatives: … « ‹
      trail = "·", -- BULLET (U+2022, UTF-8: E2 80 A2) •
    },
    diffopt = {
      "vertical",
      "iwhite",
      "hiddenoff",
      "foldcolumn:0",
      "context:4",
      "algorithm:histogram",
      "indent-heuristic",
    },

    -- Behavior
    backup = false,
    completeopt = { "menu", "menuone", "noselect", "noinsert" },
    more = false,
    gdefault = false,
    wrap = false,
    report = 2,
    inccommand = "nosplit",
    complete = ".,w,b,k", -- No wins, buffs, tags, included in scanning
    breakat = [[\ \	;:,!?]], -- Long lines break chars
    showfulltag = true, -- Show tag and tidy search in completion
    joinspaces = false, -- Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
    jumpoptions = "stack", -- list of words that change the behavior of the jumplist
    virtualedit = "block",
    emoji = false, -- emoji is true by default but makes (n)vim treat all emoji as double width
    formatoptions = {
      ["1"] = true,
      ["2"] = true, -- Use indent from 2nd line of a paragraph
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
    },

    -- Wildmenu
    wildignore = "*.so,.git,.hg,.svn,.stversions,*.pyc,*.spl,*.o,*.out,*~,%*,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**,*/.sass-cache/*,application/vendor/**,**/vendor/ckeditor/**,media/vendor/**,__pycache__,*.egg-info",
    wildcharm = vim.fn.char2nr(vim.api.nvim_replace_termcodes([[<C-Z>]], true, true, true)),
    wildmode = "longest,full",
    wildoptions = "pum",
    wildignorecase = true,
    pumheight = 15,
    pumblend = 10,

    -- What to save for views and sessions:
    clipboard = "unnamedplus",
    shada = "!,'300,<50,@100,s10,h",
    viewoptions = "cursor,folds",
    sessionoptions = "curdir,help,tabpages,winsize",
  }

  ---  SETTINGS  ---
  opt.shortmess:append "c"

  for k, v in pairs(default_options) do
    vim.opt[k] = v
  end
end

M.load_commands = function()
  local cmd = vim.cmd
  if rvim.common.line_wrap_cursor_movement then
    vim.cmd "set whichwrap+=<,>,[,],h,l,~"
  end

  vim.g.vimsyn_embed = "lPr" -- allow embedded syntax highlighting for lua,python and ruby
  vim.o.switchbuf = "useopen,uselast"
  vim.opt.spellsuggest:prepend { 12 }

  if rvim.common.transparent_window then
    cmd "au ColorScheme * hi Normal ctermbg=none guibg=none"
    cmd "au ColorScheme * hi SignColumn ctermbg=none guibg=none"
    cmd "au ColorScheme * hi NormalNC ctermbg=none guibg=none"
    cmd "au ColorScheme * hi MsgArea ctermbg=none guibg=none"
    cmd "au ColorScheme * hi TelescopeBorder ctermbg=none guibg=none"
    cmd "au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none"
    cmd "let &fcs='eob: '"
  end
end

M.setup = function()
  M.load_options()
  M.load_commands()
end

return M
