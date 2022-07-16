return function()
  local fn = vim.fn
  rvim.nnoremap('<localleader>oc', '<Cmd>Neorg gtd capture<CR>')
  rvim.nnoremap('<localleader>ov', '<Cmd>Neorg gtd views<CR>')

  require('neorg').setup({
    configure_parsers = true,
    load = {
      ['core.defaults'] = {},
      ['core.integrations.telescope'] = {},
      ['core.keybinds'] = {
        config = {
          default_keybinds = true,
          neorg_leader = '<localleader>',
          hook = function(keybinds)
            keybinds.unmap('norg', 'n', '<C-s>')
            keybinds.map_event('norg', 'n', '<C-x>', 'core.integrations.telescope.find_linkable')
          end,
        },
      },
      ['core.norg.completion'] = {
        config = {
          engine = 'nvim-cmp',
        },
      },
      ['core.norg.concealer'] = {},
      ['core.norg.dirman'] = {
        config = {
          workspaces = {
            notes = fn.expand('$HOME/notes/src/'),
            tasks = fn.expand('$HOME/notes/src/'),
            work = fn.expand('$HOME/notes/src/'),
            dotfiles = fn.expand('$HOME/.dots/neorg/'),
          },
        },
      },
      ['core.gtd.base'] = {
        config = {
          workspace = 'tasks',
        },
      },
    },
  })
end
