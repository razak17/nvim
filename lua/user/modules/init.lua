local fmt, fn, ui = string.format, vim.fn, rvim.ui
local hl, border = rvim.highlight, ui.current.border
local function sync(path) return fmt('%s/notes/%s', fn.expand(vim.env.HOME), path) end

return {
  'kazhala/close-buffers.nvim',
  'nvim-lua/plenary.nvim',
  'nvim-lua/popup.nvim',
  'kkharji/sqlite.lua',

  {
    'razak17/cybu.nvim',
    event = { 'BufRead', 'BufNewFile' },
    keys = {
      { 'H', '<cmd>Cybu prev<CR>', desc = 'cybu: prev' },
      { 'L', '<cmd>Cybu next<CR>', desc = 'cybu: next' },
    },
    opts = {
      position = { relative_to = 'win', anchor = 'topright' },
      style = { border = 'single', hide_buffer_id = true },
    },
  },
  {
    'razak17/buffer_manager.nvim',
    keys = {
      {
        '<tab>',
        function() require('buffer_manager.ui').toggle_quick_menu() end,
        desc = 'buffer_manager: toggle',
      },
    },
    config = function()
      require('buffer_manager').setup({
        borderchars = ui.border.common,
      })
      hl.plugin('buffer_manager', {
        theme = {
          ['zephyr'] = {
            { BufferManagerTitle = { fg = { from = 'Winbar' } } },
            { BufferManagerBorder = { fg = { from = 'FloatBorder' } } },
          },
        },
      })
    end,
  },
  {
    'is0n/jaq-nvim',
    cmd = 'Jaq',
    keys = {
      { '<leader>rr', ':silent only | Jaq<CR>', desc = 'jaq: run' },
    },
    opts = {
      cmds = {
        external = {
          typescript = 'ts-node %',
          javascript = 'node %',
          python = 'python %',
          rust = 'cargo run',
          cpp = 'g++ % -o $fileBase && ./$fileBase',
          go = 'go run %',
        },
      },
      behavior = { default = 'float', startinsert = true },
      ui = { float = { border = border } },
      terminal = { position = 'vert', size = 60 },
    },
  },
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' },
    },
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth = 35
    end,
  },
  {
    'karb94/neoscroll.nvim', -- NOTE: alternative: 'declancm/cinnamon.nvim'
    keys = {
      { '<C-u>', '<cmd>lua require("neoscroll").scroll(-0.10)<CR>', desc = 'neoscroll: up' },
      { '<C-d>', '<cmd>lua require("neoscroll").scroll(0.10)<CR>', desc = 'neoscroll: down' },
      { '<C-b>', '<cmd>lua require("neoscroll").scroll(-0.50)<CR>', desc = 'neoscroll: up' },
      { '<C-f>', '<cmd>lua require("neoscroll").scroll(0.50)<CR>', desc = 'neoscroll: down' },
    },
    opts = { hide_cursor = true },
  },
  {
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff',
    keys = {
      { '<localleader>ll', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
    },
  },
  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    keys = {
      {
        '<leader>sr',
        '<cmd>lua require("persistence").load()<CR>',
        desc = 'persistence: restore for directory',
      },
      {
        '<leader>sl',
        '<cmd>lua require("persistence").load({ last = true })<CR>',
        desc = 'persistence: restore last',
      },
    },
    opts = {
      dir = fn.expand(rvim.get_cache_dir() .. '/sessions/'),
      options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help' },
    },
  },
  {
    'vhyrro/neorg',
    ft = 'norg',
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
          },
        },
      },
    },
  },
}
