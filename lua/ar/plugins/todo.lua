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
      local function jump(options)
        local todo = require('todo-comments')
        return ar.jump(function(opts)
          if opts.forward then todo.jump_next() end
          if not opts.forward then todo.jump_prev() end
        end, options)
      end
      map('n', ']t', jump({ forward = true }), { desc = 'next todo' })
      map('n', '[t', jump({ forward = false }), { desc = 'previous todo' })
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>tj', function() require('todo-comments').jump_next() end, desc = 'todo-comments: next todo', },
      { '<localleader>tk', function() require('todo-comments').jump_prev() end, desc = 'todo-comments: prev todo', },
    },
    opts = { highlight = { after = '' } },
    config = function(_, opts) require('todo-comments').setup(opts) end,
  },
}
