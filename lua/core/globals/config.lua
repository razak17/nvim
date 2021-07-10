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
  relative_number = false,
  numberwidth = 4,
  shiftwidth = 2,
  tabstop = 2,
  cmdheight = 2,
  cursorline = true,
  shell = "/bin/zsh",
  scrolloff = 2,
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
  session_directory = vim.fn.stdpath("data") .. 'session/dashboard',
}

core.nvim_tree = {
  side = 'right',
  auto_open = 0,
  width = 35,
  indent_markers = 1,
  lsp_diagnostics = 0,
  special_files = {'README.md', 'Makefile', 'MAKEFILE'},
}

core.telescope = {
  prompt_prefix = " ❯ ",
  layout_config = {height = 0.9, width = 0.9},
  borderchars = {'─', '│', '─', '│', '┌', '┐', '┘', '└'},
}

core.active = {
  debug = false,
  dapinstall = false,
  symbols_outline = false,
  trouble = false,
  bfq = true,
  rainbow = false,
  matchup = false,
  autotag = true,
  fold_cycle = false,
  accelerated_jk = true,
  easy_align = false,
  fterm = false,
  colorizer = false,
  eft = false,
  cursorword = false,
  indent_line = false,
  tree = false,
  telescope_fzy = true,
  telescope_project = false,
  telescope_media_files = false,
}

core.utils = {
  leader_key = " ",
  vnsip_dir = vim.fn.stdpath "config" .. "/snippets",
  dapinstall_dir = vim.fn.stdpath "cache" .. "/dap/",
  transparent_window = false,
  auto_complete = true,
  format_on_save = true,
  document_highlight = true,
  lsp = {popup_border = "single"},
}
