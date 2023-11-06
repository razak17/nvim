return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    'tpope/vim-dadbod',
    'kristijanhusak/vim-dadbod-completion',
    {
      'kristijanhusak/vim-dadbod-completion',
      ft = { 'sql', 'mysql', 'plsql' },
    },
  },
  keys = {
    { '<leader>dt', '<Cmd>DBUIToggle<CR>', desc = 'dadbod: toggle' },
    {
      '<leader>da',
      '<Cmd>DBUIAddConnection<CR>',
      desc = 'dadbod: add connection',
    },
  },
  cmd = {
    'DBUI',
    'DBUIAddConnection',
    'DBUIClose',
    'DBUIToggle',
    'DBUIFindBuffer',
    'DBUIRenameBuffer',
    'DBUILastQueryInfo',
  },
  config = function()
    vim.g.db_ui_notification_width = 1
    vim.g.db_ui_debug = 1
    vim.g.db_ui_save_location = join_paths(vim.fn.stdpath('data'), 'db_ui')

    rvim.augroup('dad-bod', {
      event = { 'FileType' },
      pattern = { 'sql' },
      command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
    }, {
      event = { 'FileType' },
      pattern = { 'sql', 'mysql', 'plsql' },
      command = function()
        vim.schedule(
          function()
            require('cmp').setup.buffer({
              sources = { { name = 'vim-dadbod-completion' } },
            })
          end
        )
      end,
    })
  end,
}
