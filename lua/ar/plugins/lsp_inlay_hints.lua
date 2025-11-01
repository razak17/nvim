return {
  {
    'chrisgrieser/nvim-lsp-endhints',
    cond = function()
      return ar.get_plugin_cond('nvim-lsp-endhints', ar.lsp.enable)
    end,
    event = 'LspAttach',
    opts = {
      icons = { type = '󰜁 ', parameter = '󰏪 ' },
      label = { padding = 1, marginLeft = 0 },
      autoEnableHints = ar_config.lsp.inlay_hint.enable,
    },
  },
  {
    'Davidyz/inlayhint-filler.nvim',
    -- NOTE: Doesn't work when nvim-lsp-endhints is enabled
    cond = function()
      return ar.get_plugin_cond('inlayhint-filler.nvim', ar.lsp.enable)
    end,
    keys = {
      {
        '<leader>lH',
        function() require('inlayhint-filler').fill() end,
        desc = 'insert inlay-hint under cursor intobuffer.',
      },
    },
  },
}
