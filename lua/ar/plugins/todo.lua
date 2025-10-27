local minimal = ar.plugins.minimal

return {
  {
    'razak17/todo-comments.nvim',
    cond = function()
      return ar.get_plugin_cond('todo-comments.nvim', not minimal)
    end,
    event = 'BufReadPost',
    cmd = {
      'TodoTelescope',
      'TodoFzfLua',
      'TodoTrouble',
      'TodoQuickFix',
      'TodoDots',
    },
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>t', group = 'TODO' })
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>tj', function() require('todo-comments').jump_next() end, desc = 'todo-comments: next todo', },
      { '<localleader>tk', function() require('todo-comments').jump_prev() end, desc = 'todo-comments: prev todo', },
    },
    config = function()
      require('todo-comments').setup({ highlight = { after = '' } })
    end,
  },
}
