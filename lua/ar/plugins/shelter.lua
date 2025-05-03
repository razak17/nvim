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
    keys = function()
      local keys = {
        { '<leader>ep', '<Cmd>EcologPeek<CR>', desc = 'ecolog: peek variable' },
        { '<leader>el', '<Cmd>EcologShelterLinePeek<CR>', desc = 'ecolog: peek line' },
      }
      if ar_config.picker.variant == 'snacks' then
        table.insert(keys, { '<leader>f;', '<Cmd>EcologSnacks<CR>', desc = 'snacks: ecolog' })
      elseif ar_config.picker.variant == 'fzf-lua' then
        table.insert(keys, { '<leader>f;', '<Cmd>EcologFzf<CR>', desc = 'picker: ecolog' })
      end
      return keys
    end,
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Ecolog Shelter'] = 'EcologShelterToggle',
      })
      ar.add_to_select_menu('command_palette', {
        ['Ecolog Select'] = 'EcologSelect',
        ['Ecolog Goto'] = 'EcologGoto',
        ['Ecolog Goto Var'] = 'EcologGotoVar',
      })
      if ar_config.completion.variant == 'omnifunc' then
        ar.augroup('EcologOmniFunc', {
          event = { 'FileType' },
          pattern = { 'javascript', 'typescript', 'python', 'lua' },
          command = function(args)
            vim.api.nvim_set_option_value(
              'omnifunc',
              "v:lua.require'ecolog.integrations.cmp.omnifunc'.complete",
              { buf = args.buf }
            )
          end,
        })
      end
    end,
    ft = { 'config' },
    lazy = false,
    opts = {
      load_shell = true,
      vim_env = true,
      preferred_environment = 'local',
      types = true,
      integrations = {
        fzf = ar_config.picker.variant == 'fzf-lua',
        snacks = ar_config.picker.variant == 'snacks',
        omnifunc = { auto_setup = false },
        nvim_cmp = ar_config.completion.variant == 'cmp',
        blink_cmp = ar_config.completion.variant == 'blink',
        lspsaga = false,
        lsp = false, -- TODO: check this out later
        statusline = true,
      },
      shelter = {
        configuration = { partial_mode = true, mask_char = '*' },
        modules = {
          files = true,
          peek = false,
          cmp = true,
          telescope = true,
          telescope_previewer = true,
          fzf = true,
          fzf_previewer = true,
          snacks_previewer = true,
          snacks = true,
        },
      },
      path = vim.fn.getcwd(),
    },
  },
}
