local minimal = ar.plugins.minimal

return {
  {
    'ariel-frischer/bmessages.nvim',
    cond = function() return ar.get_plugin_cond('bmessages.nvim', not minimal) end,
    cmd = { 'Bmessages', 'Bmessagesvs', 'Bmessagessp', 'BmessagesEdit' },
    event = 'CmdlineEnter',
    opts = {},
  },
  {
    'smjonas/live-command.nvim',
    cond = function()
      return ar.get_plugin_cond('live-command.nvim', not minimal)
    end,
    event = 'VeryLazy',
    opts = {
      commands = {
        Norm = { cmd = 'norm' },
        G = { cmd = 'g' },
        D = { cmd = 'd' },
        LSubvert = { cmd = 'Subvert' },
      },
    },
    config = function(_, opt) require('live-command').setup(opt) end,
  },
  {
    'assistcontrol/readline.nvim',
    cond = function() return ar.get_plugin_cond('readline.nvim') end,
    -- stylua: ignore
    keys = {
      { '<M-f>', function() require('readline').forward_word() end, mode = '!' },
      { '<M-b>', function() require('readline').backward_word() end, mode = '!' },
      { '<C-a>', function() require('readline').beginning_of_line() end, mode = '!' },
      { '<C-e>', function() require('readline').end_of_line() end, mode = '!' },
      { '<M-d>', function() require('readline').kill_word() end, mode = '!' },
      { '<M-BS>', function() require('readline').backward_kill_word() end, mode = '!' },
      { '<C-w>', function() require('readline').unix_word_rubout() end, mode = '!' },
      { '<C-k>', function() require('readline').kill_line() end, mode = '!' },
      { '<C-u>', function() require('readline').backward_kill_line() end, mode = '!' },
    },
  },
}
