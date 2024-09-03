local minimal = ar.plugins.minimal

return {
  {
    'chrishrb/gx.nvim',
    cond = not ar.use_local_gx and not minimal,
    keys = { { 'gx', '<cmd>Browse<cr>', mode = { 'n', 'x' } } },
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
      require('which-key').add({ { '<localleader>u', group = 'URL' } })
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
}
