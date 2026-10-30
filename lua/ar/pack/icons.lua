local function get_cond(plugin, v)
  if ar.config.explorer.variant == 'fyler' then
    return ar.get_plugin_cond(plugin)
  end
  return ar.get_plugin_cond(plugin, ar.config.icons.variant == v)
end

local picker = ar.config.picker.variant

ar.pack.add({
  {
    src = 'https://github.com/nvim-mini/mini.icons',
    lazy = false,
    cond = get_cond('mini.icons', 'mini.icons'),
    setup = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end

      vim.schedule(function()
        require('mini.icons').setup({
          file = {
            ['init.lua'] = { glyph = '󰢱', hl = 'MiniIconsAzure' }, -- disable nvim glyph: https://github.com/nvim-mini/mini.nvim/issues/1384
            ['README.md'] = { glyph = '' },
            ['.ignore'] = { glyph = '󰈉', hl = 'MiniIconsGrey' },
            ['pre-commit'] = { glyph = '󰊢' },
          },
          filetype = {
            dotenv = { glyph = '', hl = 'MiniIconsYellow' },
            css = { glyph = '', hl = 'MiniIconsRed' },
            typescript = { hl = 'MiniIconsCyan' },
            vim = { glyph = '' }, -- used for `obsidian.vimrc`
            -- plugin-filetypes
            snacks_input = { glyph = '󰏫' },
            snacks_notif = { glyph = '󰎟' },
            noice = { glyph = '󰎟' },
            mason = { glyph = '' },
            ['ccc-ui'] = { glyph = '' },
            ['scissors-snippet'] = { glyph = '󰩫' },
            ['rip-substitute'] = { glyph = '' },
          },
          extension = {
            conf = { glyph = '', hl = 'MiniIconsBlue' },
            ['d.ts'] = { hl = 'MiniIconsRed' }, -- distinguish `.d.ts` from `.ts`
            applescript = { glyph = '󰀵', hl = 'MiniIconsGrey' },
            log = { glyph = '󱂅', hl = 'MiniIconsGrey' },
            gitignore = { glyph = '' },
          },
        })
      end)
    end,
  },
  {
    src = 'https://github.com/nvim-tree/nvim-web-devicons',
    lazy = false,
    cond = get_cond('nvim-web-devicons', 'nvim-web-devicons'),
  },
  {
    src = 'https://github.com/2kabhishek/nerdy.nvim',
    cond = ar.get_plugin_cond('nerdy.nvim', not ar.plugins.minimal),
    cmd = { 'Nerdy' },
    init = function()
      ar.add_to_select('command_palette', { ['Nerdy'] = 'Nerdy list' })
    end,
    setup = function() require('nerdy').setup() end,
  },
  {
    src = 'https://github.com/SaptanshuWanjari/icon-picker.nvim',
    cond = ar.get_plugin_cond('icon-picker.nvim', ar.plugins.coding),
    cmd = { 'IconPicker' },
    keys = {
      { '<leader>oI', '<Cmd>IconPicker<CR>', desc = 'icon_picker: open' },
      {
        '<C-g>i',
        '<Cmd>IconPicker<CR>',
        mode = 'i',
        desc = 'icon_picker: open',
      },
    },
    setup = function()
      require('icon_picker').setup({
        command = 'IconPicker',
        keymaps = { normal = nil, insert = nil },
        picker = {
          toggle_source_key = '<C-t>',
          notify_source_toggle = false,
          stopinsert_on_open = true,
          snacks = {
            layout = { preset = 'large_with_preview' },
          },
          ui = picker == 'telescope' and picker or 'snacks',
        },
      })
    end,
  },
})
