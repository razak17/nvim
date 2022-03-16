return {
  leader = "space",
  localleader = "space",
  plugins = {
    SANE = true,
    packer = { active = true },
  },
  transparent_window = false,
  line_wrap_cursor_movement = false,
  snippets_dir = join_paths(rvim.get_config_dir(), "snippets"),
  format_on_save = {
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = "*",
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 1000,
  },
  save_on_focus_lost = true,
  format_on_focus_lost = false,
  debug = false,
  defer = false,
  colorscheme = "zephyr",
  node_path = os.getenv "HOME" .. "/.fnm/node-versions/v17.3.0/installation/bin/neovim-node-host",
  python_path = rvim.get_cache_dir() .. "/venv/neovim/bin/python3",
  telescope_borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  lang = {},
  log = {
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
  },
}
