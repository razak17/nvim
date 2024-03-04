local fmt, fn = string.format, vim.fn
local function sync(path)
  return fmt('%s/notes/%s', fn.expand('$SYNC_DIR'), path)
end

return {
  {
    'epwalsh/obsidian.nvim',
    event = 'BufRead ' .. sync('obsidian') .. '/*.md',
    -- stylua: ignore
    keys = {
      { '<localleader>ob', '<Cmd>ObsidianBacklinks<CR>', desc = 'obsidian: buffer backlinks', },
      { '<localleader>od', '<Cmd>ObsidianToday<CR>', desc = 'obsidian: open daily note', },
      { '<localleader>on', ':ObsidianNew ', desc = 'obsidian: new note' },
      { '<localleader>oy', '<Cmd>ObsidianYesterday<CR>', desc = 'obsidian: previous daily note', },
      { '<localleader>oo', ':ObsidianOpen ', desc = 'obsidian: open in app' },
      { '<localleader>os', '<Cmd>ObsidianSearch<CR>', desc = 'obsidian: search', },
      { '<localleader>ot', '<Cmd>ObsidianTemplate<CR>', desc = 'obsidian: insert template', },
    },
    opts = {
      dir = sync('obsidian'),
      notes_subdir = 'Zettelkasten',
      daily_notes = { folder = 'Daily Notes' },
      templates = {
        subdir = 'Templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
      },
      finder = 'fzf-lua',
      mappings = {},
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-telescope/telescope.nvim',
      'ibhagwan/fzf-lua',
    },
  },
  {
    'nvim-neorg/neorg',
    cond = false,
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
    'lukas-reineke/headlines.nvim',
    cond = rvim.treesitter.enable and rvim.plugins.niceties,
    ft = { 'org', 'norg', 'markdown', 'yaml' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      org = { headline_highlights = false },
      norg = {
        headline_highlights = { 'Headline' },
        codeblock_highlight = false,
      },
      markdown = {
        -- If set to false, headlines will be a single line and there will be no
        -- "fat_headline_upper_string" and no "fat_headline_lower_string"
        fat_headlines = true,
        --
        -- Lines added above and below the header line makes it look thicker
        -- "lower half block" unicode symbol hex:2584
        -- "upper half block" unicode symbol hex:2580
        fat_headline_upper_string = '▄',
        fat_headline_lower_string = '▀',
        --
        -- You could add a full block if you really like it thick ;)
        -- fat_headline_upper_string = "█",
        -- fat_headline_lower_string = "█",
        --
        -- Other set of lower and upper symbols to try
        -- fat_headline_upper_string = "▃",
        -- fat_headline_lower_string = "-",
        --
        headline_highlights = {
          'Headline1',
          'Headline2',
          'Headline3',
          'Headline4',
          'Headline5',
          'Headline6',
        },
      },
    },
    config = function(_, opts)
      -- PERF: schedule to prevent headlines slowing down opening a file
      -- Define custom highlight groups using Vimscript
      vim.cmd([[highlight Headline1 guibg=#295715 guifg=white]])
      vim.cmd([[highlight Headline2 guibg=#8d8200 guifg=white]])
      vim.cmd([[highlight Headline3 guibg=#a56106 guifg=white]])
      vim.cmd([[highlight Headline4 guibg=#7e0000 guifg=white]])
      vim.cmd([[highlight Headline5 guibg=#1e0b7b guifg=white]])
      vim.cmd([[highlight Headline6 guibg=#560b7b guifg=white]])
      -- Defines the codeblock background color to something darker
      -- vim.cmd([[highlight CodeBlock guibg=#09090d]])
      -- When you add a line of dashes with --- this specifies the color, I'm not
      -- adding a "guibg" but you can do so if you want to add a background color
      -- vim.cmd([[highlight Dash guifg=white]])

      vim.schedule(function()
        require('headlines').setup(opts)
        require('headlines').refresh()
      end)
    end,
  },
}
