local minimal = ar.plugins.minimal

return {
  {
    'arnamak/stay-centered.nvim',
    cond = not minimal,
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
