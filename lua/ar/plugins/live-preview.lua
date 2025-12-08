local minimal = ar.plugins.minimal

return {
  {
    'iamcco/markdown-preview.nvim',
    lazy = false,
    cond = function()
      return ar.get_plugin_cond('markdown-preview.nvim', not minimal)
    end,
    build = function() vim.fn['mkdp#util#install']() end,
    cmd = {
      'MarkdownPreview',
      'MarkdownPreviewStop',
      'MarkdownPreviewToggle',
    },
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    'hat0uma/prelive.nvim',
    cond = function() return ar.get_plugin_cond('prelive.nvim', not minimal) end,
    cmd = {
      'PreLiveGo',
      'PreLiveStatus',
      'PreLiveClose',
      'PreLiveCloseAll',
      'PreLiveLog',
    },
    opts = {},
  },
}
