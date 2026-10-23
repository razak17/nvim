local load_cursor

ar.pack.add({
  {
    src = 'https://github.com/arnamak/stay-centered.nvim',
    cond = function()
      return ar.get_plugin_cond('stay-centered.nvim', not ar.plugins.minimal)
    end,
    event = 'BufReadPost',
    keys = function(load) load_cursor = load end,
    init = function()
      ar.add_to_select('toggle', {
        ['Toggle Stay Centered'] = function()
          load_cursor()
          require('stay-centered').toggle()
        end,
      })
    end,

    setup = function()
      require('stay-centered').setup({
        enabled = true,
        skip_filetypes = { 'FloatermSidebar', 'VoltWindow' },
      })
    end,
  },
})
