local minimal = ar.plugins.minimal

if not ar.get_plugin_cond('todo-comments.nvim', not minimal) then return end

local loaded = false

local function load()
  if loaded then return end

  vim.pack.add(
    { 'https://github.com/razak17/todo-comments.nvim' },
    { confirm = false }
  )

  require('todo-comments').setup({ highlight = { after = '' } })

  local function jump(options)
    local todo = require('todo-comments')
    return ar.jump(function(opts)
      if opts.forward then todo.jump_next() end
      if not opts.forward then todo.jump_prev() end
    end, options)
  end
  map('n', ']t', jump({ forward = true }), { desc = 'next todo' })
  map('n', '[t', jump({ forward = false }), { desc = 'previous todo' })

  loaded = true
end

ar.pack.cmd({
  'TodoTelescope',
  'TodoFzfLua',
  'TodoTrouble',
  'TodoQuickFix',
}, load)

vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
  once = true,
  callback = load,
})

map('n', '<localleader>tj', function()
  load()
  require('todo-comments').jump_next()
end, { desc = 'todo-comments: next todo' })
map('n', '<localleader>tk', function()
  load()
  require('todo-comments').jump_prev()
end, { desc = 'todo-comments: prev todo' })

if ar.config.picker.variant == 'snacks' and ar.has('snacks.nvim') then
  local function p(source, opts)
    opts = opts or {}
    return function() Snacks.picker[source](opts) end
  end

  local function todos()
    load()
    p('todo_comments', {
      layout = { preview = 'main', preset = 'ivy' },
      title = 'All Todos',
    })()
  end

  local function todos_fixes()
    load()
    p('todo_comments', {
      keywords = { 'TODO', 'FIX', 'FIXME' },
      layout = { preview = 'main', preset = 'ivy' },
      title = 'TODO/FIXME Todos',
    })()
  end

  local function config_todos()
    load()
    p('todo_comments', {
      keywords = { 'TODO', 'FIX', 'FIXME' },
      layout = { preview = 'main', preset = 'ivy' },
      cwd = vim.fn.stdpath('config'),
      title = 'Config Todos',
    })()
  end

  map('n', '<leader>ft', todos, { desc = 'todo' })
  map('n', '<leader>fF', todos_fixes, { desc = 'todo/fixme' })
  map('n', '<leader>fC', config_todos, { desc = 'config todo/fixme' })
end

if ar.config.picker.variant == 'telescope' then
  local function todos(opts)
    return function()
      load()
      if not require('ar.pack.telescope') then return end
      vim.g.telescope_add_extension({ 'todo-comments' })
      require('telescope').extensions['todo-comments'].todo(
        require('telescope.themes').get_ivy(vim.tbl_extend('force', {
          wrap_results = true,
        }, opts))
      )
    end
  end

  map(
    'n',
    '<leader>ft',
    todos({ prompt_title = 'All Todos' }),
    { desc = 'todos' }
  )
  map(
    'n',
    '<leader>fF',
    todos({
      keywords = 'TODO,FIX,FIXME',
      prompt_title = 'TODO/FIXME Todos',
    }),
    { desc = 'todo/fixme' }
  )
  map(
    'n',
    '<leader>fC',
    todos({
      keywords = 'TODO,FIX,FIXME',
      cwd = vim.fn.stdpath('config'),
      prompt_title = 'Config Todos',
    }),
    { desc = 'config todo/fixme' }
  )
end

if ar.config.picker.variant == 'fzf-lua' and ar.has('fzf-lua') then
  local function todos(opts)
    return function()
      load()
      require('todo-comments.fzf').todo(opts)
    end
  end
  map('n', '<leader>ft', todos(), { desc = 'todos' })
  map(
    'n',
    '<leader>fF',
    todos({ keywords = { 'TODO', 'FIX', 'FIXME' } }),
    { desc = 'todo/fixme' }
  )
  map(
    'n',
    '<leader>fC',
    todos({
      keywords = { 'TODO', 'FIX', 'FIXME' },
      cwd = vim.fn.stdpath('config'),
    }),
    { desc = 'config todo/fixme' }
  )
end
