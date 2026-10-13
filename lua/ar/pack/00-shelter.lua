local function get_cond(plugin, which)
  local variant = ar.config.shelter.variant
  local condition = ar.config.shelter.enable and variant == which
  return ar.get_plugin_cond(plugin, condition)
end

ar.pack.add({
  {
    src = 'https://github.com/ck-zhang/obfuscate.nvim',
    cond = ar.get_plugin_cond('obfuscate.nvim', not ar.plugins.minimal),
    init = function()
      ar.add_to_select(
        'toggle',
        { ['Toggle Obfuscate'] = 'lua require("obfuscate").toggle()' }
      )
    end,
  },
  {
    src = 'https://github.com/zeybek/camouflage.nvim',
    cond = get_cond('camouflage.nvim', 'camouflage'),
    lazy = false,
    init = function()
      ar.add_to_select('toggle', { ['Toggle Camouflage'] = 'CamouflageToggle' })
    end,
    setup = function()
      require('camouflage').setup({
        enabled = true,
        style = 'stars',
        integrations = {
          telescope = false,
          cmp = { disable_in_masked = false },
        },
        pwned = {
          enabled = true,
          auto_check = false,
          check_on_save = true,
          check_on_change = true,
          show_sign = true,
        },
      })
    end,
  },
  {
    src = 'https://github.com/laytan/cloak.nvim',
    cond = get_cond('cloak.nvim', 'cloak'),
    lazy = false,
    init = function()
      ar.add_to_select('toggle', { ['Toggle Cloak'] = 'CloakToggle' })
    end,
    setup = function()
      require('cloak').setup({
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
      })
    end,
  },
  {
    src = 'https://github.com/razak17/shelter.nvim',
    cond = get_cond('shelter.nvim', 'shelter'),
    lazy = false,
    init = function()
      -- Detect filetypes before early BufReadPost redraws (for example, Quickfile).
      vim.cmd('filetype on')
      ar.add_to_select('toggle', {
        ['Toggle Shelter'] = 'Shelter toggle',
      })
      ar.add_to_select('command_palette', {
        ['Shelter Peek'] = 'Shelter peek',
      })
    end,
    build = function() vim.cmd('ShelterBuild') end,
    setup = function()
      require('shelter').setup({
        default_mode = 'full', -- 'partial' | 'full' | 'none'
        env_filetypes = { 'dotenv', 'sh', 'conf', 'config', 'env' },
        highlight_group = 'Comment',
        mask_char = '*',
        skip_comments = false,
        modules = {
          files = {
            shelter_on_leave = true,
            disable_cmp = function() return ar.has('blink.cmp') end,
          },
          fzf_previewer = function() return ar.has('fzf-lua') end,
          snacks_previewer = function() return ar.has('snacks.nvim') end,
          telescope_previewer = function() return ar.has('telescope.nvim') end,
        },
      })
    end,
  },
})
