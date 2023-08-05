local fmt, fn = string.format, vim.fn
local function sync(path) return fmt('%s/notes/%s', fn.expand('$SYNC_DIR'), path) end

return {
  {
    'epwalsh/obsidian.nvim',
    event = { 'BufReadPre ' .. sync('obsidian/**.md') },
    keys = {
      { '<localleader>ob', '<Cmd>ObsidianBacklinks<CR>', desc = 'obsidian: buffer backlinks' },
      { '<localleader>od', '<Cmd>ObsidianToday<CR>', desc = 'obsidian: open daily note' },
      { '<localleader>on', ':ObsidianNew ', desc = 'obsidian: new note' },
      { '<localleader>oy', '<Cmd>ObsidianYesterday<CR>', desc = 'obsidian: previous daily note' },
      { '<localleader>oo', ':ObsidianOpen ', desc = 'obsidian: open in app' },
      { '<localleader>os', '<Cmd>ObsidianSearch<CR>', desc = 'obsidian: search' },
      { '<localleader>ot', '<Cmd>ObsidianTemplate<CR>', desc = 'obsidian: insert template' },
    },
    opts = {
      dir = sync('obsidian'),
      notes_subdir = 'Zettelkasten',
      daily_notes = { folder = 'Daily Notes' },
      templates = { subdir = 'Templates' },
      finder = 'fzf-lua',
    },
    config = function(_, opts)
      require('obsidian').setup(opts)
      vim.keymap.set('n', 'gf', function()
        if require('obsidian').util.cursor_on_markdown_link() then
          return '<cmd>ObsidianFollowLink<CR>'
        else
          return 'gf'
        end
      end, { noremap = false, expr = true })
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-telescope/telescope.nvim',
      'ibhagwan/fzf-lua',
    },
  },
  {
    'nvim-neorg/neorg',
    enabled = false,
    ft = 'norg',
    keys = {
      { '<localleader>nx', '<cmd>Neorg return<CR>', 'neorg: return' },
      { '<localleader>ni', '<cmd>Neorg index<CR>', 'neorg: open default' },
    },
    build = ':Neorg sync-parsers',
    dependencies = { 'vhyrro/neorg-telescope', 'max397574/neorg-contexts' },
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
        ['external.context'] = {},
      },
    },
  },
  {
    'lukas-reineke/headlines.nvim',
    enabled = rvim.treesitter.enable and not rvim.plugins.minimal,
    ft = { 'org', 'norg', 'markdown', 'yaml' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      org = { headline_highlights = false },
      norg = { headline_highlights = { 'Headline' }, codeblock_highlight = false },
      markdown = { headline_highlights = { 'Headline1' } },
    },
  },
}
