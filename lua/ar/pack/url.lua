local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

ar.pack.add({
  {
    src = 'https://github.com/chrishrb/gx.nvim',
    cond = function()
      local condition = ar.config.gx.enable
        and ar.config.gx.variant == 'gx.nvim'
      return ar.get_plugin_cond('gx.nvim', condition)
    end,
    keys = { { 'gx', '<Cmd>Browse<cr>', mode = { 'n', 'x' } } },
    cmd = { 'Browse' },
    init = function() vim.g.netrw_nogx = 1 end,
    setup = function() require('gx').setup() end,
  },
  {
    src = 'https://github.com/axieax/urlview.nvim',
    cmd = { 'UrlView' },
    cond = function() return ar.get_plugin_cond('urlview.nvim', not minimal) end,
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>u', group = 'URL' })
    end,
    keys = {
      {
        '<localleader>ub',
        '<cmd>UrlView buffer<cr>',
        desc = 'urlview: buffers',
      },
      { '<localleader>ul', '<cmd>UrlView pack<cr>', desc = 'urlview: plugins' },
      {
        '<localleader>uc',
        '<cmd>UrlView buffer action=clipboard<cr>',
        desc = 'urlview: copy links',
      },
    },
    setup = function()
      require('urlview.search').pack = function()
        local urls = {}
        for _, plugin in ipairs(vim.pack.get()) do
          urls[#urls + 1] = plugin.spec.src
        end
        return urls
      end
      require('urlview').setup({
        default_title = 'Links:',
        default_picker = 'native',
        default_prefix = 'https://',
        default_action = 'system',
      })
    end,
  },
  {
    src = 'https://github.com/rubiin/highlighturl.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('highlighturl.nvim', condition)
    end,
    event = { 'ColorScheme', 'VeryLazy' },
    setup = function()
      vim.g.highlighturl = true
      ar.highlight.plugin('highlighturl', {
        theme = { ['onedark'] = { { HighlightURL = { link = 'URL' } } } },
      })
    end,
  },
})
