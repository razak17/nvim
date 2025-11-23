local minimal = ar.plugins.minimal

return {
  {
    'arnamak/stay-centered.nvim',
    cond = function()
      return ar.get_plugin_cond('stay-centered.nvim', not minimal)
    end,
    event = 'BufReadPost',
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Stay Centered'] = 'lua require("stay-centered").toggle()',
      })
    end,
    opts = {
      enabled = true,
      skip_filetypes = { 'FloatermSidebar', 'VoltWindow' },
    },
  },
}
