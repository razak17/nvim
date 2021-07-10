local home = os.getenv("HOME")
local os_name = vim.loop.os_uname().sysname
local path_sep = core.__is_windows and '\\' or '/'

core._home = home .. path_sep
core.__path_sep = path_sep
core.__is_mac = os_name == 'OSX'
core.__is_linux = os_name == 'Linux'
core.__is_windows = os_name == 'Windows'
core.__cache_dir = core._home .. '.cache' .. path_sep .. 'nvim' .. path_sep
core.__vim_path = vim.fn.stdpath('config')
core.__data_dir = string.format('%s/site/', vim.fn.stdpath('data')) .. path_sep
core._asdf = core._home .. '.asdf' .. path_sep .. 'installs' .. path_sep
core._fnm = core._home .. '.fnm' .. path_sep .. 'node-versions' .. path_sep
core._dap = core.__cache_dir .. 'venv' .. path_sep .. 'dap' .. path_sep
core._golang = core._asdf .. "golang/1.16.2/go/bin/go"
core._node = core._fnm .. "v16.3.0/installation/bin/neovim-node-host"
core._python3 = core.__cache_dir .. 'venv' .. path_sep .. 'neovim' .. path_sep
core.__plugins = core.__data_dir .. 'pack' .. path_sep
core.__nvim_lsp = core.__cache_dir .. 'nvim_lsp' .. path_sep
core.__dapinstall_dir = core.__cache_dir .. path_sep .. 'dap/'
core.__vsnip_dir = core.__vim_path .. path_sep .. 'snippets'
core.__session_dir = core.__data_dir .. path_sep .. 'session/dashboard'
core.__modules_dir = core.__vim_path .. path_sep .. 'lua/modules'
core.__sumneko_root_path = core.__nvim_lsp .. 'lua-language-server' .. path_sep
core.__elixirls_root_path = core.__nvim_lsp .. 'elixir-ls' .. path_sep
core.__sumneko_binary = core.__sumneko_root_path ..
                          '/bin/Linux/lua-language-server'
core.__elixirls_binary = core.__elixirls_root_path .. '/.bin/language_server.sh'

core.sets = {
  colorcolumn = "+1",
  clipboard = "unnamedplus",
  hidden = true,
  wrap = false,
  spell = false,
  spelllang = "en",
  textwidth = 80,
  number = true,
  relative_number = true,
  numberwidth = 4,
  shiftwidth = 2,
  tabstop = 2,
  cmdheight = 2,
  cursorline = true,
  shell = "/bin/zsh",
  scrolloff = 7,
  laststatus = 2,
  showtabline = 2,
  ignorecase = true,
  smartcase = true,
  hlsearch = true,
  timeoutlen = 500,
  foldenable = true,
  foldtext = 'v:lua.folds()',
  udir = core.__cache_dir .. 'undodir',
  directory = core.__cache_dir .. 'swap',
  viewdir = core.__cache_dir .. 'view',
}

core.plugin = {
  debug = {active = false},
  doge = {active = false},
  dapinstall = {active = false},
  symbols_outline = {active = false},
  trouble = {active = false},
  bfq = {active = true},
  rainbow = {active = false},
  matchup = {active = false},
  autotag = {active = false},
  fold_cycle = {active = false},
  accelerated_jk = {active = true},
  easy_align = {active = false},
  fterm = {active = true},
  emmet = {active = false},
  dial = {active = false},
  far = {active = false},
  cool = {active = true},
  bookmarks = {active = false},
  colorizer = {active = true},
  delimitmate = {active = false},
  dashboard = {active = true},
  eft = {active = false},
  cursorword = {active = false},
  indent_line = {active = false},
  tree = {active = true},
  telescope_fzy = {active = true},
  telescope_project = {active = false},
  telescope_media_files = {active = false},
  fugitive = {active = false},
  undotree = {active = false},
  glow = {active = false},
  restconsole = {active = false},
  markdownpreview = {active = false},
  dadbod = {active = false},
  surround = {active = true},
  saga = {active = false},
}

core.telescope = {
  prompt_prefix = " ❯ ",
  layout_config = {height = 0.9, width = 0.9},
  borderchars = {'─', '│', '─', '│', '┌', '┐', '┘', '└'},
}

core.nvim_tree = {
  side = 'right',
  auto_open = 0,
  width = 35,
  indent_markers = 1,
  lsp_diagnostics = 0,
  special_files = {'README.md', 'Makefile', 'MAKEFILE'},
}

core.dashboard = {
  custom_header = {
    "                                                       ",
    "                                                       ",
    " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
    " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
    " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
    " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
    " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
    " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
    "                                                       ",
    "                                                       ",
  },
  default_executive = 'telescope',
  disable_statusline = 0,
  save_session = function() vim.cmd("SessionSave") end,
  session_directory = core.__session_dir,
}

core.utils = {
  leader_key = " ",
  dapinstall_dir = core.__data_dir,
  transparent_window = false,
}

core.lsp = {
  hoverdiagnostics = true,
  format_on_save = true,
  document_highlight = true,
  popup_border = "single",
  diagnostics = {
    signs = true,
    underline = true,
    update_in_insert = false,
    virtual_text = {spacing = 0, prefix = ""},
  },
}
