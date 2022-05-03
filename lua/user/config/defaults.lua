rvim.keys = {
  leader = "space",
  localleader = "space",
}

rvim.paths = {
  snippets = join_paths(rvim.get_config_dir(), "utils/snippets/textmate"),
  packer_compiled = join_paths(rvim.get_runtime_dir(), "site", "lua", "_compiled_rolling.lua"),
  node = join_paths(vim.env.FNMPATH, "neovim-node-host"),
  python3 = join_paths(rvim.get_cache_dir(), "venv/neovim/bin/python3"),
}

rvim.log = {
  ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
  level = "warn",
  viewer = {
    ---@usage this will fallback on "less +F" if not found
    cmd = "lnav",
    layout_config = {
      ---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
      direction = "horizontal",
      open_mapping = "",
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


rvim.util = {
  disabled_providers = { "python", "ruby", "perl" },
  ftplugin_filetypes = {
    "go",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "log",
    "lua",
    "python",
    "rust",
    "typescript",
    "typescriptreact.tsx",
    "typescriptreact",
    "yaml",
  },
  transparent_window = false,
  line_wrap_cursor_movement = false,
  format_on_save = {
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = "*",
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 1000,
  },
  save_on_focus_lost = true,
  -- format_on_focus_lost = false,
  format_on_focus_lost = {
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = "*",
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 1000,
  },
  debug = false,
  defer = false,
}

rvim.colorscheme = "zephyr"
