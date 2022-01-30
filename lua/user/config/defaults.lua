return {
  common = {
    leader = "space",
    localleader = "space",
    transparent_window = false,
    line_wrap_cursor_movement = false,
    format_on_save = {
      ---@usage pattern string pattern used for the autocommand (Default: '*')
      pattern = "*",
      ---@usage timeout number timeout in ms for the format request (Default: 1000)
      timeout = 1000,
    },
    save_on_focus_lost = true,
    format_on_focus_lost = true,
    debug = false,
    defer = false,
    colorscheme = "zephyr",
  },
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
  },
}
