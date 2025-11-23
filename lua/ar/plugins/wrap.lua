local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'rlychrisg/truncateline.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('truncateline.nvim', condition)
    end,
    cmd = { 'ToggleTruncate', 'TemporaryToggle' },
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Truncate'] = 'ToggleTruncate',
        ['Temporary Truncate'] = 'TemporaryToggle',
      })
    end,
    opts = { line_start_length = 17 },
  },
  {
    'benlubas/wrapping-paper.nvim',
    cond = function()
      return ar.get_plugin_cond('wrapping-paper.nvim', not minimal)
    end,
    -- stylua: ignore
    keys = {
      { '<leader>ww', function() require('wrapping-paper').wrap_line() end, desc = 'wrapping-paper: wrap line', },
    },
  },
}
