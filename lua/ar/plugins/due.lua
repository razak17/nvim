return {
  {
    'NFrid/due.nvim',
    -- ft = { 'markdown' },
    -- stylua: ignore
    keys = {
      { '<localleader>mc', function() require('due_nvim').draw(0) end, desc = 'due: mode', },
      { '<localleader>md', function() require('due_nvim').clean(0) end, desc = 'due: clean', },
      { '<localleader>mr', function() require('due_nvim').redraw(0) end, desc = 'due: redraw', },
      { '<localleader>mu', function() require('due_nvim').async_update(0) end, desc = 'due: async update', },
    },
    opts = {
      prescript = 'due: ', -- prescript to due data
      prescript_hi = 'Comment', -- highlight group of it
      due_hi = 'String', -- highlight group of the data itself
      ft = '*.md', -- filename template to apply aucmds :)
      today = 'TODAY', -- text for today's due
      today_hi = 'Character', -- highlight group of today's due
      overdue = 'OVERDUE', -- text for overdued
      overdue_hi = 'Error', -- highlight group of overdued
      date_hi = 'Conceal', -- highlight group of date string
      -- NOTE: needed for more complex patterns (e.g orgmode dates)
      pattern_start = '', -- start for a date string pattern
      pattern_end = '', -- end for a date string pattern
      regex_hi = [[\d*-*\d\+-\d\+\( \d*:\d*\( \a\a\)\?\)\?]],
      use_clock_time = false, -- display also hours and minutes
      use_clock_today = false, -- do it instead of TODAY
      use_seconds = false, -- if use_clock_time == true, display seconds
      default_due_time = 'midnight', -- if use_clock_time == true, calculate time
    },
    config = function(_, opts)
      local date_pattern = [[(%d%d)%-(%d%d)]]
      local datetime_pattern = date_pattern .. ' (%d+):(%d%d)' -- m, d, h, min
      local fulldatetime_pattern = '(%d%d%d%d)%-' .. datetime_pattern -- y, m, d, h, min

      vim.o.foldlevel = 99

      vim.tbl_deep_extend('force', opts, {
        date_pattern = date_pattern, -- m, d
        datetime_pattern = datetime_pattern, -- m, d, h, min
        datetime12_pattern = datetime_pattern .. ' (%a%a)', -- m, d, h, min, am/pm
        fulldatetime_pattern = fulldatetime_pattern, -- y, m, d, h, min
        fulldatetime12_pattern = fulldatetime_pattern .. ' (%a%a)', -- y, m, d, h, min, am/pm
        fulldate_pattern = '(%d%d%d%d)%-' .. date_pattern, -- y, m, d
      })

      require('due_nvim').setup(opts)
    end,
  },
}
