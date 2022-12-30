local M = {
  'folke/todo-comments.nvim',
  event = 'BufReadPre',
  cmd = { 'TodoTelescope', 'TodoTrouble', 'TodoQuickFix', 'TodoDots' },
}

function M.init()
  rvim.nnoremap(
    '<leader>tj',
    function() require('todo-comments').jump_next() end,
    'todo-comments: next todo'
  )
  rvim.nnoremap(
    '<leader>tk',
    function() require('todo-comments').jump_prev() end,
    'todo-comments: prev todo'
  )
end

function M.config()
  require('todo-comments').setup({ highlight = { after = '' } })
  rvim.command(
    'TodoDots',
    string.format('TodoTelescope cwd=%s keywords=TODO,FIXME', rvim.get_config_dir())
  )
end

return M
