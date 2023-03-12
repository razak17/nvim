local fmt, fn = string.format, vim.fn
local hl = rvim.highlight
local function sync(path) return fmt('%s/notes/%s', fn.expand(vim.env.HOME), path) end

return {
  {
    'vhyrro/neorg',
    event = 'CursorHold',
    keys = {
      { '<localleader>nx', '<cmd>Neorg return<CR>', 'neorg: return' },
      { '<localleader>ni', '<cmd>Neorg index<CR>', 'neorg: open default' },
    },
    build = ':Neorg sync-parsers',
    dependencies = { 'vhyrro/neorg-telescope' },
    opts = {
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
        ['core.norg.completion'] = { config = { engine = 'nvim-cmp' } },
        ['core.norg.concealer'] = {},
        ['core.norg.dirman'] = {
          config = {
            workspaces = {
              notes = sync('neorg/notes'),
              tasks = sync('neorg/tasks'),
              work = sync('neorg/work'),
            },
            default_workspace = 'notes',
          },
        },
      },
    },
  },
  {
    'lukas-reineke/headlines.nvim',
    ft = { 'org', 'norg', 'markdown', 'yaml' },
    config = function()
      hl.plugin('Headlines', {
        {
          Headline = {
            bold = true,
            italic = true,
            background = { from = 'Normal', alter = 20 },
          },
        },
        { Headline1 = { background = '#003c30' } },
        { Headline2 = { background = '#00441b' } },
        { Headline3 = { background = '#084081' } },
        { Dash = { background = '#0b60a1', bold = true } },
        {
          CodeBlock = {
            bold = true,
            italic = true,
            background = { from = 'Normal', alter = 30 },
          },
        },
      })
      require('headlines').setup({
        org = { headline_highlights = false },
        norg = { headline_highlights = { 'Headline' }, codeblock_highlight = false },
        markdown = { headline_highlights = { 'Headline1' } },
      })
    end,
  },
}
