local api, cmd, fn = vim.api, vim.cmd, vim.fn
local ui, highlight = rvim.ui, rvim.highlight
local border = ui.current.border

return {
  ----------------------------------------------------------------------------------------------------
  -- Core {{{3
  ----------------------------------------------------------------------------------------------------
  'nvim-lua/plenary.nvim',
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
      save_dir = fn.expand(vim.fn.stdpath('cache') .. '/sessions/'),
      ignored_dirs = { vim.fn.stdpath('data') },
      on_autoload_no_session = function() cmd.Alpha() end,
      should_autosave = function() return vim.bo.filetype ~= 'alpha' end,
    },
  },
  -- }}}
  ----------------------------------------------------------------------------------------------------
  -- LSP,Completion & Debugger {{{1
  ----------------------------------------------------------------------------------------------------
  'simrat39/rust-tools.nvim',
  'b0o/schemastore.nvim',
  {
    'razak17/lspkind.nvim',
    config = function() require('lspkind').init({ preset = 'codicons' }) end,
  },
  {
    {
      'williamboman/mason.nvim',
      keys = { { '<leader>lm', '<cmd>Mason<CR>', desc = 'mason info' } },
      build = ':MasonUpdate',
      opts = {
        registries = { 'lua:mason-registry.index', 'github:mason-org/mason-registry' },
        providers = { 'mason.providers.registry-api', 'mason.providers.client' },
        ui = { border = border, height = 0.8 },
      },
    },
    {
      'williamboman/mason-lspconfig.nvim',
      opts = { automatic_installation = true },
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
  },
  {
    'lvimuser/lsp-inlayhints.nvim',
    keys = {
      { '<leader>lth', function() require('lsp-inlayhints').toggle() end, desc = 'toggle inlay hints' },
    },
    init = function()
      rvim.augroup('InlayHintsSetup', {
        event = 'LspAttach',
        command = function(args)
          local id = vim.tbl_get(args, 'data', 'client_id')
          if not id then return end
          local client = vim.lsp.get_client_by_id(id)
          require('lsp-inlayhints').on_attach(client, args.buf)
        end,
      })
    end,
    opts = {
      inlay_hints = {
        highlight = 'Comment',
        labels_separator = ' ⏐ ',
        parameter_hints = { prefix = '󰊕' },
        type_hints = {
          prefix = '=> ',
          remove_colon_start = true,
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
    'joechrisellis/lsp-format-modifications.nvim',
    keys = {
      { '<localleader>lm', '<cmd>FormatModifications<CR>', desc = 'format-modifications: format' },
    },
  },
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    event = 'LspAttach',
    config = function() require('lsp_lines').setup() end,
  },
  -- }}}
  ----------------------------------------------------------------------------------------------------
  -- Utilities {{{1
  ----------------------------------------------------------------------------------------------------
  {
    'razak17/swenv.nvim',
    keys = {
      { '<localleader>le', '<Cmd>lua require("swenv.api").pick_venv()<CR>', desc = 'swenv: pick env' },
    },
  },
  {
    'kazhala/close-buffers.nvim',
    cmd = { 'BDelete', 'BWipeout' },
    keys = { { '<leader>c', '<Cmd>BDelete this<CR>', desc = 'buffer delete' } },
  },
  {
    'echasnovski/mini.surround',
    keys = { { 'ys', desc = 'add surrounding' }, 'ds', { 'yr', desc = 'delete surrounding' } },
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'ys', -- Add surrounding in Normal and Visual modes
          delete = 'ds', -- Delete surrounding
          find = 'yf', -- Find surrounding (to the right)
          find_left = 'yF', -- Find surrounding (to the left)
          highlight = 'yh', -- Highlight surrounding
          replace = 'yr', -- Replace surrounding
          update_n_lines = 'yn', -- Update `n_lines`
        },
      })
    end,
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
    'jghauser/fold-cycle.nvim',
    config = true,
    keys = {
      { '<BS>', function() require('fold-cycle').open() end, desc = 'fold-cycle: toggle' },
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
    'echasnovski/mini.pairs',
    event = 'InsertEnter',
    config = function() require('mini.pairs').setup() end,
  },
  {
    'karb94/neoscroll.nvim',
    event = 'BufRead',
    opts = {
      mappings = { '<C-d>', '<C-u>', '<C-y>', 'zt', 'zz', 'zb' },
      hide_cursor = true,
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
    'willothy/flatten.nvim',
    lazy = false,
    priority = 1001,
    opts = {
      window = { open = 'alternate' },
      callbacks = {
        block_end = function() require('toggleterm').toggle() end,
        post_open = function(_, winnr, _, is_blocking)
          if is_blocking then
            require('toggleterm').toggle()
          else
            api.nvim_set_current_win(winnr)
          end
        end,
      },
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
    'razak17/buffer_manager.nvim',
    keys = {
      { '<tab>', function() require('buffer_manager.ui').toggle_quick_menu() end, desc = 'buffer_manager: toggle' },
    },
    config = function() require('buffer_manager').setup({ borderchars = ui.border.common }) end,
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
          lua = 'lua %',
        },
      },
      behavior = { default = 'float', startinsert = true },
      ui = { float = { border = border } },
      terminal = { position = 'vert', size = 60 },
    },
  },
  {
    'ahmedkhalf/project.nvim',
    event = 'LspAttach',
    name = 'project_nvim',
    opts = {
      detection_methods = { 'pattern', 'lsp' },
      ignore_lsp = { 'null-ls' },
      patterns = { '.git' },
    },
  },
  {
    'razak17/lab.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      { '<leader>rl', ':Lab code run<CR>', desc = 'lab: run' },
      { '<leader>rx', ':Lab code stop<CR>', desc = 'lab: stop' },
      { '<leader>rp', ':Lab code panel<CR>', desc = 'lab: panel' },
    },
    build = 'cd js && npm ci',
    config = function()
      highlight.plugin('lab', {
        theme = {
          ['onedark'] = { { LabCodeRun = { link = 'DiagnosticVirtualTextInfo' } } },
        },
      })
      require('lab').setup()
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  -- }}}
  ----------------------------------------------------------------------------------------------------
  -- Filetype Plugins {{{1
  ----------------------------------------------------------------------------------------------------
  'yioneko/nvim-vtsls',
  { 'razak17/slides.nvim', ft = 'slide' },
  { 'fladson/vim-kitty', ft = 'kitty' },
  { 'dmmulroy/tsc.nvim', cmd = 'TSC', config = true, ft = { 'typescript', 'typescriptreact' } },
  { 'razak17/tailwind-fold.nvim', ft = { 'html', 'svelte', 'astro', 'vue', 'typescriptreact' } },
  { 'turbio/bracey.vim', ft = 'html', build = 'npm install --prefix server' },
  {
    'olexsmir/gopher.nvim',
    ft = 'go',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'iamcco/markdown-preview.nvim',
    build = function() fn['mkdp#util#install']() end,
    ft = 'markdown',
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    'NTBBloodbath/rest.nvim',
    ft = { 'http', 'json' },
    keys = {
      { '<leader>rS', '<Plug>RestNvim', desc = 'rest: run' },
      { '<leader>rP', '<Plug>RestNvimPreview', desc = 'rest: preview' },
      { '<leader>rL', '<Plug>RestNvimLast', desc = 'rest: run last' },
    },
    opts = { skip_ssl_verification = true },
  },
  {
    'razak17/package-info.nvim',
    event = 'BufRead package.json',
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      highlight.plugin('package-info', {
        theme = {
          ['onedark'] = {
            { PackageInfoUpToDateVersion = { link = 'DiagnosticVirtualTextInfo' } },
            { PackageInfoOutdatedVersion = { link = 'DiagnosticVirtualTextWarn' } },
          },
        },
      })
      require('package-info').setup({
        autostart = false,
        hide_up_to_date = true,
      })
    end,
  },
  {
    'Saecki/crates.nvim',
    event = 'BufRead Cargo.toml',
    opts = {
      popup = { autofocus = true, border = border },
      null_ls = { enabled = true, name = 'crates' },
    },
    config = function(_, opts)
      rvim.augroup('CmpSourceCargo', {
        event = 'BufRead',
        pattern = 'Cargo.toml',
        command = function()
          require('cmp').setup.buffer({
            sources = { { name = 'crates', priority = 3, group_index = 1 } },
          })
        end,
      })
      require('crates').setup(opts)
    end,
  },
  {
    'axelvc/template-string.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    opts = { remove_template_string = true },
  },
  {
    'marilari88/twoslash-queries.nvim',
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      highlight.plugin('twoslash-queries', {
        theme = {
          ['onedark'] = { { TypeVirtualText = { link = 'DiagnosticVirtualTextInfo' } } },
        },
      })
      rvim.augroup('TwoSlashQueriesSetup', {
        event = 'LspAttach',
        command = function(args)
          local id = vim.tbl_get(args, 'data', 'client_id')
          if not id then return end
          local client = vim.lsp.get_client_by_id(id)
          if client.name == 'vtsls' then require('twoslash-queries').attach(client, args.buf) end
        end,
      })
    end,
  },
  -- }}}
  ----------------------------------------------------------------------------------------------------
  -- Syntax {{{1
  ----------------------------------------------------------------------------------------------------
  {
    'psliwka/vim-dirtytalk',
    lazy = false,
    build = ':DirtytalkUpdate',
    init = function() vim.opt.spelllang:append('programming') end,
  },
  ---}}}
}
