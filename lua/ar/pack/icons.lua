local variant = ar.config.icons.variant

local function get_cond(plugin, v)
  if ar.config.explorer.variant == 'fyler' then
    return ar.get_plugin_cond(plugin)
  end
  return ar.get_plugin_cond(plugin, variant == v)
end

local coding = ar.plugins.coding
local minimal = ar.plugins.minimal
local picker = ar.config.picker.variant

if get_cond('mini.icons', 'mini.icons') then
  vim.pack.add(
    { 'https://github.com/nvim-mini/mini.icons' },
    { confirm = false }
  )

  package.preload['nvim-web-devicons'] = function()
    require('mini.icons').mock_nvim_web_devicons()
    return package.loaded['nvim-web-devicons']
  end

  vim.schedule(function()
    require('mini.icons').setup({
      file = {
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['init.lua'] = { glyph = '󰢱', hl = 'MiniIconsAzure' }, -- disable nvim glyph: https://github.com/nvim-mini/mini.nvim/issues/1384
        ['README.md'] = { glyph = '' },
        ['.ignore'] = { glyph = '󰈉', hl = 'MiniIconsGrey' },
        ['pre-commit'] = { glyph = '󰊢' },
      },
      filetype = {
        json = { glyph = '' },
        jsonc = { glyph = '' },
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
end

if get_cond('nvim-web-devicons', 'nvim-web-devicons') then
  vim.pack.add(
    { 'https://github.com/nvim-tree/nvim-web-devicons' },
    { confirm = false }
  )
end

if ar.get_plugin_cond('nerdy.nvim', not minimal) then
  local loaded = false

  local function load()
    if loaded then return end

    vim.pack.add(
      { 'https://github.com/2kabhishek/nerdy.nvim' },
      { confirm = false }
    )

    require('nerdy').setup()

    loaded = true
  end

  ar.add_to_select('command_palette', { ['Nerdy'] = 'Nerdy list' })

  ar.pack.cmd('Nerdy', load)
end

if ar.get_plugin_cond('icon-picker.nvim', coding) then
  local loaded = false

  local function load()
    if loaded then return end

    vim.pack.add(
      { 'https://github.com/SaptanshuWanjari/icon-picker.nvim' },
      { confirm = false }
    )

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

    loaded = true
  end

  ar.pack.cmd('IconPicker', load)

  map('n', '<leader>oI', function()
    load()
    vim.cmd('IconPicker')
  end, { desc = 'icon_picker: open' })
  map('i', '<C-g>i', function()
    load()
    vim.cmd('IconPicker')
  end, { desc = 'icon_picker: open' })
end
