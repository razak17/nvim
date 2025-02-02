local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'rlychrisg/truncateline.nvim',
    cond = not minimal and niceties,
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
    cond = not minimal,
    -- stylua: ignore
    keys = {
      { '<leader>ww', function() require('wrapping-paper').wrap_line() end, desc = 'wrapping-paper: wrap line', },
    },
  },
}
