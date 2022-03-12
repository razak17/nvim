return {
  leader = "space",
  localleader = "space",
  transparent_window = false,
  line_wrap_cursor_movement = false,
  snippets_dir = rvim.get_config_dir() .. "/snippets",
  format_on_save = {
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = "*",
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 1000,
  },
  keymaps = {
    ---@usage change or add keymappings for normal mode
    nmap = {},

    ---@usage change or add keymappings for visual block mode
    xmap = {},

    ---@usage change or add keymappings for insert mode
    imap = {},

    ---@usage change or add keymappings for visual mode
    vmap = {},

    ---@usage change or add keymappings for operator mode
    omap = {},

    ---@usage change or add keymappings for terminal mode
    tmap = {},

    ---@usage change or add keymappings for select mode
    smap = {},

    ---@usage change or add keymappings for command mode
    cmap = {},

    ---@usage change or add keymappings for recursive normal mode
    nnoremap = {},

    ---@usage change or add keymappings for recursive visual block mode
    xnoremap = {},

    ---@usage change or add keymappings for recursive insert mode
    inoremap = {},

    ---@usage change or add keymappings for recursive visual mode
    vnoremap = {},

    ---@usage change or add keymappings for recursive operator mode
    onoremap = {},

    ---@usage change or add keymappings for recursive terminal mode
    tnoremap = {},

    ---@usage change or add keymappings for recursive select mode
    snoremap = {},

    ---@usage change or add keymappings for recursive command mode
    cnoremap = {},
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
