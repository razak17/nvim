local fmt, fn = string.format, vim.fn
local highlight = rvim.highlight
local function sync(path) return fmt('%s/notes/%s', fn.expand(vim.env.HOME), path) end

return {
  {
    'vhyrro/neorg',
    ft = 'norg',
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
        ['core.completion'] = { config = { engine = 'nvim-cmp' } },
        ['core.concealer'] = {},
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = sync('neorg'),
              tasks = sync('neorg/neovim'),
              work = sync('neorg/work'),
            },
            default_workspace = 'notes',
          },
        },
      },
    },
  },
  {
    'razak17/headlines.nvim',
    ft = { 'org', 'norg', 'markdown', 'yaml' },
    config = function()
      highlight.plugin('Headlines', {
        {
          Headline = {
            bold = true,
            italic = true,
            bg = { from = 'Normal', alter = 0.2 },
          },
        },
        { Headline1 = { bg = '#003c30' } },
        { Headline2 = { bg = '#00441b' } },
        { Headline3 = { bg = '#084081' } },
        { Dash = { bg = '#0b60a1', bold = true } },
        {
          CodeBlock = {
            bold = true,
            italic = true,
            bg = { from = 'Normal', alter = 0.3 },
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
