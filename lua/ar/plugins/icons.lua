local minimal = ar.plugins.minimal
local ar_icons = ar_config.icons.variant

return {
  {
    'nvim-tree/nvim-web-devicons',
    cond = function()
      return ar.get_plugin_cond('nvim-web-devicons')
        and ar_icons == 'nvim-web-devicons'
    end,
  },
  {
    'echasnovski/mini.icons',
    cond = function()
      return ar.get_plugin_cond('mini.icons') and ar_icons == 'mini.icons'
    end,
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
    opts = {
      file = {
        ['init.lua'] = { glyph = '󰢱', hl = 'MiniIconsAzure' }, -- disable nvim glyph: https://github.com/echasnovski/mini.nvim/issues/1384
        ['README.md'] = { glyph = '' },
        ['.ignore'] = { glyph = '󰈉', hl = 'MiniIconsGrey' },
        ['pre-commit'] = { glyph = '󰊢' },
      },
      extension = {
        ['d.ts'] = { hl = 'MiniIconsRed' }, -- distinguish `.d.ts` from `.ts`
        ['applescript'] = { glyph = '󰀵', hl = 'MiniIconsGrey' },
        ['log'] = { glyph = '󱂅', hl = 'MiniIconsGrey' },
        ['gitignore'] = { glyph = '' },
      },
      filetype = {
        ['css'] = { glyph = '', hl = 'MiniIconsRed' },
        ['typescript'] = { hl = 'MiniIconsCyan' },
        ['vim'] = { glyph = '' }, -- used for `obsidian.vimrc`

        -- plugin-filetypes
        ['snacks_input'] = { glyph = '󰏫' },
        ['snacks_notif'] = { glyph = '󰎟' },
        ['noice'] = { glyph = '󰎟' },
        ['mason'] = { glyph = '' },
        ['ccc-ui'] = { glyph = '' },
        ['scissors-snippet'] = { glyph = '󰩫' },
        ['rip-substitute'] = { glyph = '' },
      },
      config = function(_, opts)
        require('mini.icons').setup(opts)
        -- plugin still needing the devicons mock: telescope
        require('mini.icons').mock_nvim_web_devicons()
      end,
    },
  },
  {
    '2kabhishek/nerdy.nvim',
    cmd = { 'Nerdy' },
    cond = function() return ar.get_plugin_cond('nerdy.nvim', not minimal) end,
    init = function()
      ar.add_to_select_menu('command_palette', { ['Nerdy'] = 'Nerdy list' })
    end,
    opts = { use_new_command = true },
  },
}
