local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'chrishrb/gx.nvim',
    cond = function()
      local condition = ar.config.gx.enable
        and ar.config.gx.variant == 'plugin'
        and not minimal
      return ar.get_plugin_cond('gx.nvim', condition)
    end,
    keys = { { 'gx', '<Cmd>Browse<cr>', mode = { 'n', 'x' } } },
    cmd = { 'Browse' },
    init = function() vim.g.netrw_nogx = 1 end,
    opts = {},
    submodules = false,
  },
  {
    'axieax/urlview.nvim',
    cmd = { 'UrlView' },
    cond = function() return ar.get_plugin_cond('urlview.nvim', not minimal) end,
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>u', group = 'URL' })
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>ub', '<cmd>UrlView buffer<cr>', desc = 'urlview: buffers' },
      { '<localleader>ul', '<cmd>UrlView lazy<cr>', desc = 'urlview: lazy' },
      { '<localleader>uc', '<cmd>UrlView buffer action=clipboard<cr>', desc = 'urlview: copy links' },
    },
    opts = {
      default_title = 'Links:',
      default_picker = 'native',
      default_prefix = 'https://',
      default_action = 'system',
    },
  },
  {
    'rubiin/highlighturl.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('highlighturl.nvim', condition)
    end,
    event = 'ColorScheme',
    config = function()
      vim.g.highlighturl = true
      ar.highlight.plugin('highlighturl', {
        theme = { ['onedark'] = { { HighlightURL = { link = 'URL' } } } },
      })
    end,
  },
}
