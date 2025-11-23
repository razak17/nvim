local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'tpope/vim-eunuch',
    cond = function() return ar.get_plugin_cond('vim-eunuch') end,
    cmd = {
      'Cfind',
      'Chmod',
      'Clocate',
      'Copy',
      'Delete',
      'Duplicate',
      'Lfind',
      'Llocate',
      'Mkdir',
      'Move',
      'Remove',
      'Rename',
      'SudoEdit',
      'SudoWrite',
      'Wall',
    },
  },
  {
    'lambdalisue/suda.vim',
    cond = function() return ar.get_plugin_cond('suda.vim', false) end,
    lazy = false,
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Re-open File With Sudo Permissions'] = 'SudaRead',
        ['Write File With Sudo Permissions'] = 'SudaWrite',
      })
    end,
  },
  {
    'chrisgrieser/nvim-genghis',
    cond = function() return ar.get_plugin_cond('nvim-genghis', not minimal) end,
    event = { 'BufReadPost', 'BufNewFile' },
    init = function()
      vim.g.whichkey_add_spec({ '<leader><localleader>f', group = 'Genghis' })
    end,
    -- stylua: ignore
    keys = {
      { '<leader><localleader>fp', '<cmd>lua require("genghis").copyFilepath()<CR>', desc = 'genghis: yank filepath' },
      { '<leader><localleader>ff', '<cmd>lua require("genghis").copyFilename()<CR>', desc = 'genghis: yank filename' },
      { '<leader><localleader>fr', '<cmd>lua require("genghis").renameFile()<CR>', desc = 'genghis: rename file' },
      { '<leader><localleader>fm', '<cmd>lua require("genghis").moveAndRenameFile()<CR>', desc = 'genghis: move and rename' },
      { '<leader><localleader>fn', '<cmd>lua require("genghis").createNewFile()<CR>', desc = 'genghis: create new file' },
      { '<leader><localleader>fD', '<cmd>lua require("genghis").duplicateFile()<CR>', desc = 'genghis: duplicate current file' },
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
  {
    'bgaillard/readonly.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('readonly.nvim', condition)
    end,
    lazy = false,
    opts = {
      secured_files = {
        '~/%.aws/config',
        '~/%.aws/credentials',
        '~/%.ssh/.',
        '~/%.secrets.yaml',
        '~/%.vault-crypt-files/.',
      },
    },
  },
}
