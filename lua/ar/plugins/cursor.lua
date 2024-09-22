local minimal = ar.plugins.minimal

return {
  {
    'arnamak/stay-centered.nvim',
    cond = not minimal,
    event = 'BufReadPost',
    init = function()
      ar.add_to_menu('toggle', {
        ['Toggle Stay Centered'] = 'lua require("stay-centered").toggle()',
      })
    end,
    opts = { enabled = true },
  },
  {
    'rlychrisg/keepcursor.nvim',
    cond = not minimal,
    cmd = {
      'ToggleCursorTop',
      'ToggleCursorBot',
      'ToggleCursorMid',
      'ToggleCursorRight',
      'ToggleCursorLeft',
    },
    init = function()
      ar.add_to_menu('toggle', {
        ['Toggle Cursor Top'] = 'ToggleCursorTop',
        ['Toggle Cursor Bottom'] = 'ToggleCursorBot 2',
        ['Toggle Cursor Middle'] = 'ToggleCursorMid',
        ['Toggle Cursor Right'] = 'ToggleCursorRight 30',
        ['Toggle Cursor Left'] = 'ToggleCursorLeft',
      })
    end,
    opts = {
      enabled_on_start_v = 'none',
      enabled_on_start_h = 'none',
    },
  },
}
