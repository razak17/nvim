ar.pack.add({
  {
    src = 'https://github.com/tpope/vim-eunuch',
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
    src = 'https://github.com/lambdalisue/suda.vim',
    cond = function() return ar.get_plugin_cond('suda.vim') end,
    lazy = false,
    init = function()
      ar.add_to_select('command_palette', {
        ['Re-open File With Sudo Permissions'] = 'SudaRead',
        ['Write File With Sudo Permissions'] = 'SudaWrite',
      })
    end,
  },
  {
    src = 'https://github.com/bgaillard/readonly.nvim',
    cond = function()
      return ar.get_plugin_cond('readonly.nvim', not ar.plugins.minimal)
    end,
    lazy = false,
    setup = function()
      require('readonly').setup({
        secured_files = {
          '~/%.aws/config',
          '~/%.aws/credentials',
          '~/%.ssh/.',
          '~/%.secrets.yaml',
          '~/%.vault-crypt-files/.',
        },
      })
    end,
  },
})
