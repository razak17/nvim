local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'chrishrb/gx.nvim',
    cond = ar_config.gx.enable
      and ar_config.gx.variant == 'plugin'
      and not minimal,
    keys = { { 'gx', '<Cmd>Browse<cr>', mode = { 'n', 'x' } } },
    cmd = { 'Browse' },
    init = function() vim.g.netrw_nogx = 1 end,
    opts = {},
    submodules = false,
  },
  {
    'axieax/urlview.nvim',
    cmd = { 'UrlView' },
    cond = not minimal,
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
    cond = not minimal and niceties,
    event = 'ColorScheme',
    config = function()
      vim.g.highlighturl = true
      ar.highlight.plugin('highlighturl', {
        theme = { ['onedark'] = { { HighlightURL = { link = 'URL' } } } },
      })
    end,
  },
}
