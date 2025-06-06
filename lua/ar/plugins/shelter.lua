local minimal = ar.plugins.minimal
local variant = ar_config.shelter.variant
local is_avail = ar.is_available
local is_fzf = ar_config.picker.variant == 'fzf-lua'
local is_snacks = ar_config.picker.variant == 'snacks'
local is_cmp = ar_config.completion.variant == 'cmp'
local is_blink = ar_config.completion.variant == 'blink'

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
    cond = function()
      local condition = cond and variant == 'ecolog'
      return ar.get_plugin_cond('ecolog.nvim', condition)
    end,
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
      -- stylua: ignore
      integrations = {
        telescope = function() return is_avail('telescope.nvim') end,
        fzf = function () return is_fzf and is_avail('fzf-lua') end,
        snacks = function () return is_snacks and is_avail('snacks.nvim') end,
        nvim_cmp = function () return is_avail('blink.cmp') end,
        blink_cmp = function() return is_blink and is_avail('blink.cmp') end,
        -- blink_cmp = true,
        omnifunc = { auto_setup = false },
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
          telescope = is_avail('telescope.nvim'),
          telescope_previewer = is_avail('telescope.nvim'),
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
