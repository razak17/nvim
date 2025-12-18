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
    cond = function() return ar.get_plugin_cond('suda.vim') end,
    lazy = false,
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Re-open File With Sudo Permissions'] = 'SudaRead',
        ['Write File With Sudo Permissions'] = 'SudaWrite',
      })
    end,
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
