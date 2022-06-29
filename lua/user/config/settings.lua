local vim = vim

local M = {}

M.load_default_options = function()
  local default_options = {
    encoding = "utf-8",
    fileencoding = "utf-8",
    swapfile = false,
    undofile = true,

    -- Neovim Directories
    udir = rvim.get_cache_dir() .. "/undodir",
    directory = rvim.get_cache_dir() .. "/swap",
    viewdir = rvim.get_cache_dir() .. "/view",

    -- Timing
    timeout = true,
    timeoutlen = 250,
    ttimeoutlen = 10,
    updatetime = 100,

    -- Folds
    foldenable = true,
    foldlevelstart = 2,
    -- foldtext = "v:lua.folds()",
    foldmethod = "expr",

    -- Splits and buffers
    splitbelow = true,
    splitright = true,
    eadirection = "hor",

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
    -- spelllang = { "en" },
    spell = true,
    spelloptions = "camel",
    spellfile = join_paths(rvim.get_config_dir(), "spell", "en.utf-8.add"),
    fileformats = { "unix", "mac", "dos" }, -- don't check for capital letters at start of sentence

    -- Display
    conceallevel = 0,
    concealcursor = "niv",
    linebreak = true,
    synmaxcol = 1024,
    signcolumn = "auto:2-5",
    ruler = false,
    cmdheight = 1,
    cmdwinheight = 5,
    background = "dark",

    -- Tabs and Indents
    breakindentopt = "shift:2,min:20",
    smarttab = true, -- Tab insert blanks according to 'shiftwidth'
    tabstop = 2,
    shiftwidth = 2,
    textwidth = 0,
    softtabstop = -1,
    expandtab = true,
    cindent = true, -- Increase indent on line after opening brace
    autoindent = true, -- Use same indenting on new lines
    shiftround = true, -- Round indent to multiple of 'shiftwidth'
    smartindent = true,

    -- Editor UI Appearance
    colorcolumn = "",
    cursorcolumn = false,
    laststatus = 3,
    showtabline = 2,
    showmode = false,
    termguicolors = true,
    guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:block",
    sidescrolloff = 5,
    scrolloff = 7,
    winblend = 10,
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
      msgsep = " ", -- alternatives: ‾ ─
      foldopen = "▾",
      foldsep = "│",
      foldclose = "▸",
    },
    listchars = {
      eol = " ",
      nbsp = "+",
      tab = "  ", -- Alternatives: '▷▷', │, »
      extends = "", -- Alternatives: … » ›
      precedes = "", -- Alternatives: … « ‹
      trail = "·", -- BULLET (U+2022, UTF-8: E2 80 A2) •
    },
    diffopt = vim.opt.diffopt + {
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
    writebackup = false,
    mouse = "a",
    mousefocus = true,
    showcmd = false,
    completeopt = { "menu", "menuone", "noselect", "noinsert" },
    more = false,
    gdefault = false,
    wrap = false,
    report = 2,
    complete = ".,w,b,k", -- No wins, buffs, tags, included in scanning
    breakat = [[\ \	;:,!?]], -- Long lines break chars
    showfulltag = true, -- Show tag and tidy search in completion
    joinspaces = false, -- Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
    jumpoptions = { "stack" }, -- make the jumplist behave like a browser stack
    virtualedit = "block",
    emoji = false, -- emoji is true by default but makes (n)vim treat all emoji as double width
    switchbuf = "useopen,uselast",
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
    wildignore = "*.so,.git,.hg,.svn,*.pyc,*.spl,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,__pycache__",
    wildcharm = vim.fn.char2nr(vim.api.nvim_replace_termcodes([[<C-Z>]], true, true, true)),
    wildmode = "longest,full",
    wildoptions = "pum",
    wildignorecase = true,
    pumheight = 15,
    pumblend = 10,

    -- clipboard
    clipboard = "unnamedplus",

    -- What to save for views and sessions:
    viewoptions = "cursor,folds",
    sessionoptions = {
      "globals",
      "buffers",
      "curdir",
      "winpos",
      "tabpages",
    },
    autowriteall = true, -- automatically :write before running commands and changing files

    -- title
    title = true,
    titlelen = 70,
    -- titlestring = ' ❐ %{fnamemodify(getcwd(), ":t")} %m'
    titlestring = "%<%F%=%l/%L - nvim",
  }

  ---  SETTINGS  ---
  vim.opt.shortmess:append("c")
  vim.opt.iskeyword:append("-")
  vim.opt.shadafile = join_paths(rvim.get_cache_dir(), "shada", "rvim.shada")
  vim.opt.spellsuggest:prepend({ 12 })
  vim.opt.spelllang:append("programming")

  for k, v in pairs(default_options) do
    vim.opt[k] = v
  end
end

M.load_commands = function()
  local command_options = {
    exrc = true,
    secure = true,
    magic = true,
    noerrorbells = true,
    t_Co = 256,
    shell = "/bin/zsh",
  }

  local cmd = vim.cmd

  for k, v in pairs(command_options) do
    if v == true or v == false then
      cmd("set " .. k)
    else
      cmd("set " .. k .. "=" .. v)
    end
  end

  if rvim.util.line_wrap_cursor_movement then
    cmd("set whichwrap+=<,>,[,],h,l,~")
  end

  if rvim.util.transparent_window then
    require("user.utils").enable_transparent_mode()
  end
end

M.load_headless_options = function()
  vim.opt.shortmess = "" -- try to prevent echom from cutting messages off or prompting
  vim.opt.more = false -- don't pause listing when screen is filled
  vim.opt.cmdheight = 9999 -- helps avoiding |hit-enter| prompts.
  vim.opt.columns = 9999 -- set the widest screen possible
  vim.opt.swapfile = false -- don't use a swap file
end

M.load_options = function()
  if #vim.api.nvim_list_uis() == 0 then
    M.load_headless_options()
    return
  end
  M.load_default_options()
end

function M:init()
  M.load_commands()
  M.load_options()
end

return M
