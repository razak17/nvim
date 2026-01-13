local minimal = ar.plugins.minimal
local variant = ar.config.shelter.variant
local is_fzf = ar.config.picker.variant == 'fzf-lua'
local is_snacks = ar.config.picker.variant == 'snacks'
local is_blink = ar.config.completion.variant == 'blink'

local cond = not minimal and ar.config.shelter.enable

local function get_cond(plugin, which)
  local condition = cond and variant == which
  return ar.get_plugin_cond(plugin, condition)
end

return {
  {
    'ck-zhang/obfuscate.nvim',
    cond = function() return ar.get_plugin_cond('obfuscate.nvim', not minimal) end,
    init = function()
      ar.add_to_select_menu(
        'toggle',
        { ['Toggle Obfuscate'] = 'lua require("obfuscate").toggle()' }
      )
    end,
  },
  {
    'laytan/cloak.nvim',
    cond = function()
      if minimal then return ar.get_plugin_cond('cloak.nvim') end
      return get_cond('cloak.nvim', 'cloak')
    end,
    lazy = false,
    init = function()
      ar.add_to_select_menu('toggle', { ['Toggle Cloak'] = 'CloakToggle' })
    end,
    opts = {
      patterns = {
        {
          file_pattern = {
            '.env*',
            '*.env.*',
            '*.secret.*',
            'secrets',
          },
          cloak_pattern = '=.+',
        },
      },
    },
  },
  {
    {
      'ph1losof/ecolog.nvim',
      cond = function() return get_cond('ecolog.nvim', 'ecolog') end,
      -- stylua: ignore
      keys = function()
        local keys = {
          { '<leader>ep', '<Cmd>EcologPeek<CR>', desc = 'ecolog: peek variable' },
          { '<leader>el', '<Cmd>EcologShelterLinePeek<CR>', desc = 'ecolog: peek line' },
        }
        if is_snacks then
          table.insert(keys, { '<leader>f;', '<Cmd>EcologSnacks<CR>', desc = 'snacks: ecolog' })
        elseif is_fzf then
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
        if ar.config.completion.variant == 'omnifunc' then
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
          telescope = function() return ar.has('telescope.nvim') end,
          fzf = function () return is_fzf and ar.has('fzf-lua') end,
          snacks = function () return is_snacks and ar.has('snacks.nvim') end,
          nvim_cmp = function () return ar.has('blink.cmp') end,
          blink_cmp = function() return is_blink and ar.has('blink.cmp') end,
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
            telescope = ar.has('telescope.nvim'),
            telescope_previewer = ar.has('telescope.nvim'),
            fzf = is_fzf,
            fzf_previewer = is_fzf,
            snacks = is_snacks,
            snacks_previewer = is_snacks,
          },
        },
        path = vim.fn.getcwd(),
      },
    },
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        return get_cond()
            and vim.g.blink_add_source({ 'ecolog' }, {
              ecolog = {
                name = '[ECOLOG]',
                module = 'ecolog.integrations.cmp.blink_cmp',
              },
            }, opts)
          or opts
      end,
    },
    {
      'nvim-telescope/telescope.nvim',
      optional = true,
      keys = function(_, keys)
        if get_cond() then
          table.insert(keys or {}, {
            '<leader>f;',
            function()
              require('telescope').extensions.ecolog.env(
                ar.telescope.minimal_ui()
              )
            end,
            desc = 'ecolog',
          })
        end
      end,
      opts = function(_, opts)
        return get_cond() and vim.g.telescope_add_extension({ 'ecolog' }, opts)
          or opts
      end,
    },
  },
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    opts = function(_, opts)
      vim.g.cmp_add_source(opts, {
        source = {
          name = 'ecolog',
          group_index = 1,
        },
        menu = { ecolog = '[ECOLOG]' },
      })
    end,
  },
}
