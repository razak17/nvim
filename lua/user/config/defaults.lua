rvim.keys = {
  leader = 'space',
  localleader = ',',
}

rvim.paths = {
  snippets = join_paths(rvim.get_config_dir(), 'snippets', 'textmate'),
  packer_compiled = join_paths(rvim.get_runtime_dir(), 'site', 'lua', '_compiled_rolling.lua'),
  node = join_paths(vim.env.FNMPATH, 'neovim-node-host'),
  python3 = join_paths(rvim.get_cache_dir(), 'venv', 'neovim', 'bin', 'python3'),
  vscode_lldb = join_paths(vim.env.HOME, '.vscode-oss', 'extensions', 'vadimcn.vscode-lldb-1.7.0'),
  mason = join_paths(rvim.get_runtime_dir(), 'mason'),
}

rvim.log = {
  ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
  level = 'warn',
  viewer = {
    ---@usage this will fallback on "less +F" if not found
    cmd = 'lnav',
    layout_config = {
      ---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
      direction = 'horizontal',
      open_mapping = '',
      size = 40,
      float_opts = {},
    },
  },
  -- currently disabled due to instabilities
  override_notify = false,
}

rvim.plugins = {
  SANE = true,
  packer = { active = true },
}

rvim.ui = {
  line_wrap_cursor_movement = false,
  transparent_window = false,
  defer = false,
  winbar_ft_icon = false,
}

rvim.util = {
  disabled_providers = { 'python', 'ruby', 'perl' },
  ftplugin_filetypes = {
    'go',
    'graphql',
    'html',
    'json',
    'jsonc',
    'log',
    'lua',
    'python',
    'yaml',
  },
  format_on_save = {
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = '*',
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 2000,
    ---@usage filter func to select client
    filter = require('user.utils.lsp').format_filter,
  },
  save_on_focus_lost = true,
  format_on_focus_lost = false,
  autoinstall_ts_parsers = true,
  debug = false,
}

rvim.colorscheme = 'zephyr'
