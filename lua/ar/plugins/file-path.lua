local coding = ar.plugins.coding

return {
  {
    'chrisgrieser/nvim-genghis',
    cond = function() return ar.get_plugin_cond('nvim-genghis', coding) end,
    event = { 'BufReadPost', 'BufNewFile' },
    init = function()
      vim.g.whichkey_add_spec({ '<leader><localleader>f', group = 'Genghis' })
    end,
    -- stylua: ignore
    keys = {
      { '<leader><localleader>fp', '<Cmd>lua require("genghis").copyFilepath()<CR>', desc = 'genghis: yank filepath' },
      { '<leader><localleader>ff', '<Cmd>lua require("genghis").copyFilename()<CR>', desc = 'genghis: yank filename' },
      { '<leader><localleader>fr', '<Cmd>lua require("genghis").renameFile()<CR>', desc = 'genghis: rename file' },
      { '<leader><localleader>fm', '<Cmd>lua require("genghis").moveAndRenameFile()<CR>', desc = 'genghis: move and rename' },
      { '<leader><localleader>fn', '<Cmd>lua require("genghis").createNewFile()<CR>', desc = 'genghis: create new file' },
      { '<leader><localleader>fD', '<Cmd>lua require("genghis").duplicateFile()<CR>', desc = 'genghis: duplicate current file' },
      {
        '<leader><localleader>fd',
        function ()
          if vim.fn.confirm('Delete file?', '&Yes\n&No') == 1 then
            require('genghis').trashFile()
          end
        end,
        desc = 'genghis: move to trash',
      },
    },
  },
}
