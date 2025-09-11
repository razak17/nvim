return {
  {
    desc = 'readline style keybindings in insert mode',
    'tpope/vim-rsi',
    cond = function() return ar.get_plugin_cond('vim-rsi', not minimal) end,
    event = { 'InsertEnter' },
  },
  {
    'assistcontrol/readline.nvim',
    cond = function() return ar.get_plugin_cond('readline.nvim', false) end,
    event = { 'InsertEnter' },
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
