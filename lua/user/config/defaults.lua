rvim.path = {
  snippets = join_paths(rvim.get_config_dir(), 'snippets', 'textmate'),
  python = join_paths(rvim.get_cache_dir(), 'venv', 'neovim', 'bin', 'python3'),
  mason = join_paths(vim.call('stdpath', 'data'), 'mason'),
}

rvim.ui = {
  line_wrap_cursor_movement = false,
  transparent_window = false,
  tw = {},
  winbar = {
    enable = true,
    use_filename_only = true,
    use_file_icon = false,
  },
}

rvim.lang = { format_on_save = true }

rvim.keys = { leader = 'space', localleader = ',' }

rvim.plugins = { SANE = true }

rvim.util = {
  disabled_providers = { 'python', 'ruby', 'perl' },
  disabled_builtins = {
    '2html_plugin',
    'gzip',
    'matchit',
    'rrhelper',
    'netrw',
    'netrwPlugin',
    'netrwSettings',
    'netrwFileHandlers',
    'zip',
    'zipPlugin',
    'tar',
    'tarPlugin',
    'getscript',
    'getscriptPlugin',
    'vimball',
    'vimballPlugin',
    'logipat',
    'spellfile_plugin',
  },
  auto_save = true,
}
