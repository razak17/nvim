return {
  {
    'NFrid/due.nvim',
    ft = 'markdown',
    opts = {
      use_clock_time = true,
      use_clock_today = true,
      use_seconds = false,
    },
    config = function(_, opts) require('due_nvim').setup(opts) end,
  },
}
