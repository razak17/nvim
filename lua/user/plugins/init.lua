local api, cmd, fn = vim.api, vim.cmd, vim.fn
local ui, hl = rvim.ui, rvim.highlight
local border = ui.current.border

return {
  'nvim-lua/plenary.nvim',
  'kkharji/sqlite.lua',
  'simrat39/rust-tools.nvim',
  'jose-elias-alvarez/typescript.nvim',
  'marilari88/twoslash-queries.nvim',

  {
    'kazhala/close-buffers.nvim',
    keys = {
      { '<leader>c', function() require('close_buffers').delete({ type = 'this' }) end, desc = 'delete buffer' },
    },
  },
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>lm', '<cmd>Mason<CR>', { desc = 'mason: info' } } },
    build = ':MasonUpdate',
    opts = {
      registries = { 'lua:mason-registry.index', 'github:mason-org/mason-registry' },
      providers = { 'mason.providers.registry-api', 'mason.providers.client' },
      ui = { border = border, height = 0.8 },
    },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require('mason-lspconfig').setup({ automatic_installation = true }) end,
    dependencies = {
      'mason.nvim',
      {
        'neovim/nvim-lspconfig',
        config = function() require('lspconfig.ui.windows').default_options.border = border end,
        dependencies = {
          {
            'folke/neodev.nvim',
            ft = 'lua',
            opts = {
              debug = true,
              experimental = { pathStrict = true },
              library = {
                runtime = join_paths(vim.env.HOME, 'neovim', 'share', 'nvim', 'runtime'),
                plugins = { 'neotest' },
                types = true,
              },
            },
          },
        },
      },
    },
  },
  {
    'ray-x/lsp_signature.nvim',
    event = 'InsertEnter',
    opts = {
      bind = true,
      fix_pos = false,
      auto_close_after = 15, -- close after 15 seconds
      hint_enable = false,
      handler_opts = { border = border },
      toggle_key = '<C-K>',
      select_signature_key = '<M-N>',
    },
  },
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
    'echasnovski/mini.bufremove',
    enabled = false,
    keys = {
      { '<leader>c', function() require('mini.bufremove').delete(0, false) end, desc = 'delete buffer' },
    },
  },
  {
    'razak17/buffer_manager.nvim',
    keys = {
      { '<tab>', function() require('buffer_manager.ui').toggle_quick_menu() end, desc = 'buffer_manager: toggle' },
    },
    config = function() require('buffer_manager').setup({ borderchars = ui.border.common }) end,
  },
  {
    'olimorris/persisted.nvim',
    lazy = false,
    init = function()
      rvim.command('ListSessions', 'Telescope persisted')
      rvim.augroup('PersistedEvents', {
        event = 'User',
        pattern = 'PersistedTelescopeLoadPre',
        command = function()
          vim.schedule(function() cmd('%bd') end)
        end,
      }, {
        event = 'User',
        pattern = 'PersistedSavePre',
        -- Arguments are always persisted in a session and can't be removed using 'sessionoptions'
        -- so remove them when saving a session
        command = function() cmd('%argdelete') end,
      })
    end,
    opts = {
      use_git_branch = true,
      save_dir = fn.expand(vim.call('stdpath', 'cache') .. '/sessions/'),
      ignored_dirs = { vim.call('stdpath', 'data') },
      on_autoload_no_session = function() cmd.SessionLoadLast() end,
      should_autosave = function() return vim.bo.filetype ~= 'alpha' end,
    },
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
    'karb94/neoscroll.nvim',
    event = 'VeryLazy',
    opts = {
      mappings = { '<C-d>', '<C-u>', '<C-y>', 'zt', 'zz', 'zb' },
      hide_cursor = true,
    },
  },
  {
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff',
    keys = {
      { '<localleader>ll', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
    },
  },
  {
    'joechrisellis/lsp-format-modifications.nvim',
    keys = {
      { '<localleader>lm', '<cmd>FormatModifications<CR>', desc = 'format-modifications: format' },
    },
  },
  {
    'SmiteshP/nvim-navic',
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = {
      highlight = false,
      icons = ui.current.lsp_icons,
      depth_limit_indicator = ui.icons.misc.ellipsis,
      lsp = { auto_attach = true },
      separator = (' %s '):format(ui.icons.misc.triangle),
    },
  },
  {
    'razak17/glance.nvim',
    keys = {
      { 'gD', '<Cmd>Glance definitions<CR>', desc = 'lsp: glance definitions' },
      { 'gR', '<Cmd>Glance references<CR>', desc = 'lsp: glance references' },
      { 'gY', '<Cmd>Glance type_definitions<CR>', desc = 'lsp: glance type definitions' },
      { 'gM', '<Cmd>Glance implementations<CR>', desc = 'lsp: glance implementations' },
    },
    config = function()
      require('glance').setup({
        preview_win_opts = { relativenumber = false },
        hl.plugin('glance', {
          { GlanceWinBarFilename = { link = 'Error' } },
          { GlanceWinBarFilepath = { link = 'StatusLine' } },
          { GlanceWinBarTitle = { link = 'StatusLine' } },
        }),
      })
    end,
  },
  {
    'olexsmir/gopher.nvim',
    ft = 'go',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'kosayoda/nvim-lightbulb',
    event = 'LspAttach',
    config = function()
      hl.plugin('Lightbulb', {
        { LightBulbFloatWin = { fg = { from = 'Type' } } },
        { LightBulbVirtualText = { fg = { from = 'Type' } } },
      })
      local icon = ui.icons.misc.lightbulb
      require('nvim-lightbulb').setup({
        ignore = { 'null-ls' },
        autocmd = { enabled = true },
        sign = { enabled = false },
        virtual_text = { enabled = true, text = icon, hl_mode = 'blend' },
        float = { text = icon, enabled = false, win_opts = { border = 'none' } }, -- 
      })
    end,
  },
  {
    'lvimuser/lsp-inlayhints.nvim',
    event = 'LspAttach',
    keys = {
      { '<leader>lth', function() require('lsp-inlayhints').toggle() end, desc = 'toggle inlay hints' },
    },
    opts = {
      inlay_hints = {
        highlight = 'Comment',
        labels_separator = ' ⏐ ',
        parameter_hints = {
          prefix = '',
        },
        type_hints = {
          prefix = '=> ',
          remove_colon_start = true,
        },
      },
    },
  },
  {
    'andymass/vim-matchup',
    event = 'BufReadPost',
    keys = { { '<localleader>lw', ':<c-u>MatchupWhereAmI?<CR>', desc = 'matchup: where am i' } },
    config = function() vim.g.matchup_matchparen_enabled = 0 end,
  },
  {
    'ckolkey/ts-node-action',
    keys = {
      { '<localleader>ct', function() require('ts-node-action').node_action() end, desc = 'ts-node-action: run' },
    },
    config = function()
      require('ts-node-action').setup({
        typescriptreact = {
          ['string_fragment'] = require('ts-node-action.actions').conceal_string('…'),
        },
        html = {
          ['attribute_value'] = require('ts-node-action.actions').conceal_string('…'),
        },
      })
    end,
  },
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    event = 'LspAttach',
    config = function() require('lsp_lines').setup() end,
  },
  {
    'jghauser/fold-cycle.nvim',
    config = true,
    keys = {
      { '<BS>', function() require('fold-cycle').open() end, desc = 'fold-cycle: toggle' },
    },
  },
  {
    'psliwka/vim-dirtytalk',
    build = ':DirtytalkUpdate',
    init = function() vim.opt.spelllang:append('programming') end,
  },
  {
    'andrewferrier/debugprint.nvim',
    keys = {
      {
        '<leader>dp',
        function() return require('debugprint').debugprint({ variable = true }) end,
        expr = true,
        desc = 'debugprint: cursor',
      },
      {
        '<leader>do',
        function() return require('debugprint').debugprint({ motion = true }) end,
        mode = 'o',
        expr = true,
        desc = 'debugprint: operator',
      },
      { '<leader>dx', '<Cmd>DeleteDebugPrints<CR>', desc = 'debugprint: clear all' },
    },
    opts = { create_keymaps = false },
  },
  {
    'willothy/flatten.nvim',
    lazy = false,
    priority = 1001,
    opts = {
      window = { open = 'alternate' },
      callbacks = {
        block_end = function() require('toggleterm').toggle() end,
        post_open = function(bufnr, winnr, ft, is_blocking)
          if is_blocking then
            require('toggleterm').toggle()
          else
            api.nvim_set_current_win(winnr)
          end
          if ft == 'gitcommit' then
            api.nvim_create_autocmd('BufWritePost', {
              buffer = bufnr,
              once = true,
              callback = function()
                vim.defer_fn(function() cmd.Bwipeout() end, 50)
              end,
            })
          end
        end,
      },
    },
  },
}
