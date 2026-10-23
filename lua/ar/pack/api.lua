ar.pack.add({
  {
    src = 'https://github.com/mistweaverco/kulala.nvim',
    cond = function()
      return ar.get_plugin_cond('kulala.nvim', ar.plugins.coding and false)
    end,
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
      { '<leader>rks', ':lua require("kulala").scratchpad()<CR>', desc = 'kulala: scratchpad' },
      { '<leader>rkt', ':lua require("kulala").toggle_view()<CR>', desc = 'kulala: toggle view', ft = "http" },
    },
    setup = function() require('kulala').setup({ default_env = 'local' }) end,
  },
  {
    src = 'https://github.com/zerochae/endpoint.nvim',
    cond = function()
      return ar.get_plugin_cond('endpoint.nvim', not ar.plugins.coding)
    end,
    cmd = { 'Endpoint', 'EndpointRefresh' },
    setup = function() require('endpoint').setup() end,
  },
})
