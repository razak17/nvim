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
      { '<leader>rke', ':lua require("kulala").set_selected_env()<CR>', desc = 'kulala: select env', ft = "http" },
      { '<leader>rkc', ':lua require("kulala").copy()<CR>', desc = 'kulala: copy as curl command', ft = "http" },
      { "<leader>rkC", ':lua require("kulala").fiom_curl()<CR>', desc = 'kulala: paste from curl', ft = "http" },
      { "<leader>rkg", ':lua require("kulala").download_graphql_schema()<CR>', desc = 'kulala: download GraphQL schema', ft = "http" },
      { '<leader>rki', ':lua require("kulala").inspect()<CR>', desc = 'kulala: inspect', ft = "http" },
      { '<leader>rkk', ':lua require("kulala").run()<CR>', desc = 'kulala: run', ft = "http" },
      { '<leader>rkn', ':lua require("kulala").jump_next()<CR>', desc = 'kulala: next', ft = "http" },
      { '<leader>rko', ':lua require("kulala").show_stats()<CR>', desc = 'kulala: stats', ft = "http" },
      { '<leader>rkp', ':lua require("kulala").jump_prev()<CR>', desc = 'kulala: prev', ft = "http" },
      { '<leader>rkq', ':lua require("kulala").close()<CR>', desc = 'kulala: close window', ft = "http" },
      { '<leader>rkr', ':lua require("kulala").replay()<CR>', desc = 'kulala: replay the last request', ft = "http" },
      { '<leader>rks', ':lua require("kulala").scratchpad()<CR>', desc = 'kulala: scratchpad', ft = "http" },
      { '<leader>rkt', ':lua require("kulala").toggle_view()<CR>', desc = 'kulala: toggle view', ft = "http" },
    },
    opts = { default_env = 'local' },
  },
  {
    'zerochae/endpoint.nvim',
    cond = not minimal,
    cmd = { 'Endpoint', 'EndpointRefresh' },
    opts = {},
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
