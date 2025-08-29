local sync = ar.sync_dir

return {
  {
    'obsidian-nvim/obsidian.nvim',
    cond = function()
      return ar.get_plugin_cond('obsidian.nvim', not ar.plugins.minimal)
    end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader><localleader>o', group = 'Obsidian' })
    end,
    event = 'BufRead ' .. sync('obsidian') .. '/*.md',
    cmd = { 'Obsidian' },
    -- stylua: ignore
    keys = {
      { '<leader><localleader>ob', '<Cmd>Obsidian backlinks<CR>', desc = 'obsidian: buffer backlinks', },
      { '<leader><localleader>od', '<Cmd>Obsidian today<CR>', desc = 'obsidian: open daily note', },
      { '<leader><localleader>on', ':Obsidian new ', desc = 'obsidian: new note' },
      { '<leader><localleader>oy', '<Cmd>Obsidian yesterday<CR>', desc = 'obsidian: previous daily note', },
      { '<leader><localleader>oo', ':Obsidian open ', desc = 'obsidian: open in app' },
      { '<leader><localleader>os', '<Cmd>Obsidian search<CR>', desc = 'obsidian: search', },
      { '<leader><localleader>ot', '<Cmd>Obsidian template<CR>', desc = 'obsidian: insert template', },
    },
    opts = {
      legacy_commands = false,
      checkbox = {
        order = {
          [' '] = { char = '', hl_group = 'ObsidianTodo' },
          ['x'] = { char = '', hl_group = 'ObsidianDone' },
          ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
          ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
          ['!'] = { char = '', hl_group = 'ObsidianImportant' },
        },
      },
      ui = {
        enable = false,
        bullets = { char = '•', hl_group = 'ObsidianBullet' },
      },
      workspaces = {
        { name = 'personal', path = sync('obsidian') },
      },
      notes_subdir = 'Zettelkasten',
      daily_notes = { folder = 'Daily Notes' },
      templates = {
        folder = sync('obsidian') .. '/99 - Meta/00 - Templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
      },
    },
  },
}
