return {
  desc = 'snacks terminal',
  recommended = true,
  'folke/snacks.nvim',
  -- stylua: ignore
  keys = function(_, keys)
    keys = keys or {}
      ar.list_insert(keys, {
        { '<leader>o/', function() Snacks.terminal.focus() end, desc = 'snacks: toggle terminal' },
      })
  end,
  opts = function(_, opts)
    ar.add_to_select('toggle', {
      ['Toggle Terminal'] = function() Snacks.terminal.focus() end,
    })

    return vim.tbl_deep_extend('force', opts or {}, {
      terminal = {
        enabled = true,
        win = {
          wo = { winbar = '' },
          position = 'right',
        },
      },
    })
  end,
}
