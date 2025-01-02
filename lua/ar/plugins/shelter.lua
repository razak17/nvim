local minimal = ar.plugins.minimal
local variant = ar.shelter.variant

local cond = not minimal and ar.shelter.enable

return {
  {
    'laytan/cloak.nvim',
    cond = cond and variant == 'cloak',
    event = 'VeryLazy',
    init = function()
      ar.add_to_menu('toggle', { ['Toggle Cloak'] = 'CloakToggle' })
    end,
    opts = {},
  },
  {
    'philosofonusus/ecolog.nvim',
    cond = cond and variant == 'ecolog',
    -- stylua: ignore
    keys = {
      { '<leader>ep', '<Cmd>EcologPeek<cr>', desc = 'ecolog: peek variable' },
      { '<leader>el', '<Cmd>EcologShelterLinePeek<cr>', desc = 'ecolog: peek line' },
    },
    init = function()
      ar.add_to_menu('toggle', {
        ['Toggle Ecolog Shelter'] = 'EcologShelterToggle',
      })
      ar.add_to_menu('command_palette', {
        ['Ecolog Select'] = 'EcologSelect',
        ['Ecolog Goto'] = 'EcologGoto',
        ['Ecolog Goto Var'] = 'EcologGotoVar',
      })
    end,
    lazy = false,
    opts = {
      preferred_environment = 'local',
      types = true,
      integrations = { lspsaga = false, lsp = false },
      shelter = {
        configuration = { partial_mode = true, mask_char = '*' },
        modules = {
          files = true,
          peek = false,
          telescope = true,
          cmp = true,
        },
      },
      path = vim.fn.getcwd(),
    },
  },
}
