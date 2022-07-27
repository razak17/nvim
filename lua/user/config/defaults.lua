rvim.keys = { leader = 'space', localleader = ',' }

rvim.paths = {
  snippets = join_paths(rvim.get_config_dir(), 'snippets', 'textmate'),
  packer_compiled = join_paths(rvim.get_runtime_dir(), 'site', 'lua', '_compiled_rolling.lua'),
  node = join_paths(vim.env.FNMPATH, 'neovim-node-host'),
  python3 = join_paths(rvim.get_cache_dir(), 'venv', 'neovim', 'bin', 'python3'),
  vscode_lldb = join_paths(vim.env.HOME, '.vscode-oss', 'extensions', 'vadimcn.vscode-lldb-1.7.0'),
  mason = join_paths(rvim.get_runtime_dir(), 'mason'),
}

rvim.plugins = { SANE = true, packer = { active = true } }

rvim.ui = {
  line_wrap_cursor_movement = false,
  transparent_window = false,
  defer = false,
  winbar_opts = {
    enable = false,
    use_filename = true,
    use_ft_icon = false,
  },
}

rvim.lang = { format_on_save = true }

rvim.util = { disabled_providers = { 'python', 'ruby', 'perl' }, save_on_focus_lost = true }

rvim.colorscheme = 'zephyr'
