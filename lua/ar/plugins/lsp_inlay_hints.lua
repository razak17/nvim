return {
  {
    'chrisgrieser/nvim-lsp-endhints',
    cond = ar.lsp.enable,
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
    cond = ar.lsp.enable and false,
    keys = {
      {
        '<leader>lH',
        function() require('inlayhint-filler').fill() end,
        desc = 'insert inlay-hint under cursor intobuffer.',
      },
    },
  },
}
