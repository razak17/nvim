rvim.paths = {
  snippets = join_paths(rvim.get_config_dir(), 'snippets', 'textmate'),
  packer_compiled = join_paths(rvim.get_runtime_dir(), 'site', 'lua', '_compiled_nightly.lua'),
  node = join_paths(vim.env.FNMPATH, 'neovim-node-host'),
  python3 = join_paths(rvim.get_cache_dir(), 'venv', 'neovim', 'bin', 'python3'),
  vscode_lldb = join_paths(vim.env.HOME, '.vscode-oss', 'extensions', 'vadimcn.vscode-lldb-1.7.3'),
  mason = join_paths(rvim.get_runtime_dir(), 'mason'),
}

rvim.ui = {
  line_wrap_cursor_movement = false,
  transparent_window = false,
  defer = false,
  winbar = {
    enable = false,
    use_filename = true,
    use_icon = false,
  },
}

rvim.lang = { format_on_save = true }
rvim.keys = {
  leader = 'space',
  localleader = ',',
}
rvim.plugins = {
  SANE = true,
  packer = { active = true },
}
rvim.util = {
  disabled_providers = { 'python', 'ruby', 'perl' },
  save_on_focus_lost = true,
}

rvim.filetypes = {
  'NeogitCommitMessage',
  'go',
  'graphql',
  'html',
  'json',
  'jsonc',
  'log',
  'lua',
  'markdown',
  'python',
  'rust',
  'vim',
  'yaml',
}
