local minimal = ar.plugins.minimal
local variant = ar_config.shelter.variant

local cond = not minimal and ar_config.shelter.enable

return {
  {
    'ck-zhang/obfuscate.nvim',
    init = function()
      ar.add_to_select_menu(
        'toggle',
        { ['Toggle Obfuscate'] = 'lua require("obfuscate").toggle()' }
      )
    end,
  },
  {
    'laytan/cloak.nvim',
    cond = cond and variant == 'cloak',
    event = 'VeryLazy',
    init = function()
      ar.add_to_select_menu('toggle', { ['Toggle Cloak'] = 'CloakToggle' })
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
      ar.add_to_select_menu('toggle', {
        ['Toggle Ecolog Shelter'] = 'EcologShelterToggle',
      })
      ar.add_to_select_menu('command_palette', {
        ['Ecolog Select'] = 'EcologSelect',
        ['Ecolog Goto'] = 'EcologGoto',
        ['Ecolog Goto Var'] = 'EcologGotoVar',
      })
    end,
    lazy = false,
    opts = {
      preferred_environment = 'local',
      types = true,
      integrations = {
        nvim_cmp = ar_config.completion.variant == 'cmp',
        blink_cmp = ar_config.completion.variant == 'blink',
        lspsaga = false,
        lsp = false,
      },
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
