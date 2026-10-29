local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

ar.pack.add({
  {
    src = 'https://github.com/rlychrisg/truncateline.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('truncateline.nvim', condition)
    end,
    cmd = { 'ToggleTruncate', 'TemporaryToggle' },
    init = function()
      ar.add_to_select('toggle', {
        ['Toggle Truncate'] = 'ToggleTruncate',
        ['Temporary Truncate'] = 'TemporaryToggle',
      })
    end,
    setup = function()
      require('truncateline').setup({ line_start_length = 17 })
    end,
  },
  {
    src = 'https://github.com/benlubas/wrapping-paper.nvim',
    cond = function()
      return ar.get_plugin_cond('wrapping-paper.nvim', not minimal)
    end,
    keys = {
      {
        '<leader>ww',
        function() require('wrapping-paper').wrap_line() end,
        desc = 'wrapping-paper: wrap line',
      },
    },
  },
})
