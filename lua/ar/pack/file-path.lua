ar.pack.add({
  {
    src = 'https://github.com/ywpkwon/yank-path.nvim',
    cond = function() return ar.get_plugin_cond('yank-path.nvim') end,
    cmd = { 'YankPath' },
    keys = {
      {
        '<leader><localleader>fo',
        '<Cmd>YankPath<CR>',
        desc = 'yank-path: file path',
      },
    },
    setup = function() require('yank-path').setup({ default_mapping = false }) end,
  },
  {
    src = 'https://github.com/chrisgrieser/nvim-genghis',
    cond = function()
      return ar.get_plugin_cond('nvim-genghis', ar.plugins.coding)
    end,
    event = { 'BufReadPost', 'BufNewFile' },
    keys = function(load)
      vim.g.whichkey_add_spec({ '<leader><localleader>f', group = 'Path' })

      local mappings = {
        { 'p', 'copyFilepath', 'yank filepath' },
        { 'f', 'copyFilename', 'yank filename' },
        { 'r', 'renameFile', 'rename file' },
        { 'm', 'moveAndRenameFile', 'move and rename' },
        { 'n', 'createNewFile', 'create new file' },
        { 'D', 'duplicateFile', 'duplicate current file' },
      }

      for _, mapping in ipairs(mappings) do
        map('n', '<leader><localleader>f' .. mapping[1], function()
          load()
          require('genghis')[mapping[2]]()
        end, { desc = 'genghis: ' .. mapping[3] })
      end

      map('n', '<leader><localleader>fd', function()
        if vim.fn.confirm('Delete file?', '&Yes\n&No') == 1 then
          load()
          require('genghis').trashFile()
        end
      end, { desc = 'genghis: move to trash' })
    end,
  },
})
