local minimal = ar.plugins.minimal

return {
  {
    'mistweaverco/kulala.nvim',
    branch = 'develop',
    cond = not minimal,
    ft = { 'http' },
    init = function()
      vim.g.whichkey_add_spec({ '<leader>rk', group = 'Kulala' })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>rke', ':lua require("kulala").set_selected_env()<CR>', desc = 'kulala: select env' },
      { '<leader>rkk', ':lua require("kulala").run()<CR>', desc = 'kulala: run' },
      { '<leader>rkn', ':lua require("kulala").jump_next()<CR>', desc = 'kulala: next' },
      { '<leader>rkp', ':lua require("kulala").jump_prev()<CR>', desc = 'kulala: prev' },
      { '<leader>rks', ':lua require("kulala").scratchpad()<CR>', desc = 'kulala: scratchpad' },
      { '<leader>rkt', ':lua require("kulala").toggle_view()<CR>', desc = 'kulala: toggle view' },
    },
    opts = { default_env = 'local' },
  },
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'rest-nvim/rest.nvim',
    enabled = false,
    cond = not minimal and false, -- archived
    ft = { 'http', 'json' },
    init = function() vim.g.whichkey_add_spec({ '<leader>rr', group = 'Rest' }) end,
    -- stylua: ignore
    keys = {
      { '<leader>rrs', '<Plug>RestNvim', desc = 'rest: run', buffer = 0 },
      { '<leader>rrp', '<Plug>RestNvimPreview', desc = 'rest: preview', buffer = 0, },
      { '<leader>rrl', '<Plug>RestNvimLast', desc = 'rest: run last', buffer = 0, },
    },
    opts = { skip_ssl_verification = true },
    config = function(_, opts) require('rest-nvim').setup(opts) end,
    dependencies = {
      { 'vhyrro/luarocks.nvim', opts = {} },
    },
  },
}
