local sync = ar.sync_dir

return {
  {
    'epwalsh/obsidian.nvim',
    cond = not ar.plugins.minimal,
    init = function()
      vim.g.whichkey_add_spec({ '<leader><localleader>o', group = 'Obsidian' })
    end,
    event = 'BufRead ' .. sync('obsidian') .. '/*.md',
    -- stylua: ignore
    keys = {
      { '<leader><localleader>ob', '<Cmd>ObsidianBacklinks<CR>', desc = 'obsidian: buffer backlinks', },
      { '<leader><localleader>od', '<Cmd>ObsidianToday<CR>', desc = 'obsidian: open daily note', },
      { '<leader><localleader>on', ':ObsidianNew ', desc = 'obsidian: new note' },
      { '<leader><localleader>oy', '<Cmd>ObsidianYesterday<CR>', desc = 'obsidian: previous daily note', },
      { '<leader><localleader>oo', ':ObsidianOpen ', desc = 'obsidian: open in app' },
      { '<leader><localleader>os', '<Cmd>ObsidianSearch<CR>', desc = 'obsidian: search', },
      { '<leader><localleader>ot', '<Cmd>ObsidianTemplate<CR>', desc = 'obsidian: insert template', },
    },
    opts = {
      dir = sync('obsidian'),
      notes_subdir = 'Zettelkasten',
      daily_notes = { folder = 'Daily Notes' },
      templates = {
        folder = sync('obsidian') .. '/99 - Meta/00 - Templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
      },
      finder = 'fzf-lua',
      mappings = {},
    },
  },
  {
    'nvim-neorg/neorg',
    cond = false,
    ft = 'norg',
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>n', group = 'Neorg' })
    end,
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
              keybinds.map_event(
                'norg',
                'n',
                '<C-x>',
                'core.integrations.telescope.find_linkable'
              )
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
    'atiladefreitas/dooing',
    cmd = { 'Dooing' },
    init = function()
      vim.g.whichkey_add_spec({ '<leader><localleader>d', group = 'Dooing' })
    end,
    keys = {
      { '<leader><localleader>do', desc = 'dooing: toggle window' },
      { '<leader><localleader>dx', desc = 'dooing: remove duplicates' },
    },
    opts = {
      keymaps = {
        toggle_window = '<leader><localleader>do',
        remove_duplicates = '<leader><localleader>dx',
      },
    },
  },
}
