local api, cmd, fn = vim.api, vim.cmd, vim.fn
local fmt = string.format
local ui, highlight = rvim.ui, rvim.highlight
local border = ui.current.border

return {
  ----------------------------------------------------------------------------------------------------
  -- Core {{{3
  ----------------------------------------------------------------------------------------------------
  'nvim-lua/plenary.nvim',
  'nvim-tree/nvim-web-devicons',
  {
    'olimorris/persisted.nvim',
    enabled = not rvim.plugins.minimal,
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
  {
    'mrjones2014/smart-splits.nvim',
    opts = {},
    build = './kitty/install-kittens.bash',
    keys = {
      -- moving between splits
      { '<C-h>', function() require('smart-splits').move_cursor_left() end },
      { '<C-j>', function() require('smart-splits').move_cursor_down() end },
      { '<C-k>', function() require('smart-splits').move_cursor_up() end },
      { '<C-l>', function() require('smart-splits').move_cursor_right() end },
      -- swapping buffers between windows
      { '<leader><leader>h', function() require('smart-splits').swap_buf_left() end, desc = { 'swap left' } },
      { '<leader><leader>j', function() require('smart-splits').swap_buf_down() end, { desc = 'swap down' } },
      { '<leader><leader>k', function() require('smart-splits').swap_buf_up() end, { desc = 'swap up' } },
      { '<leader><leader>l', function() require('smart-splits').swap_buf_right() end, { desc = 'swap right' } },
    },
  },
  -- }}}
  ----------------------------------------------------------------------------------------------------
  -- Themes {{{1
  ----------------------------------------------------------------------------------------------------
  { 'razak17/onedark.nvim', lazy = false, priority = 1000 },
  { 'LunarVim/horizon.nvim', lazy = false, priority = 1000 },
  { 'romainl/vim-cool', event = 'BufReadPre', config = function() vim.g.CoolTotalMatches = 1 end },
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
          config = function()
            require('lspconfig.ui.windows').default_options.border = border
            -- reload LspInfo floating window on VimResized
            rvim.augroup('LspInfoResize', {
              event = 'VimResized',
              pattern = '*',
              command = function()
                if vim.bo.ft == 'lspinfo' then
                  vim.api.nvim_win_close(0, true)
                  vim.cmd('LspInfo')
                end
              end,
            })
          end,
          dependencies = {
            {
              'folke/neodev.nvim',
              enabled = rvim.lsp.enable,
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
            {
              'folke/neoconf.nvim',
              enabled = rvim.lsp.enable,
              cmd = { 'Neoconf' },
              opts = { local_settings = '.nvim.json', global_settings = 'nvim.json' },
            },
          },
        },
      },
    },
  },
  {
    'lvimuser/lsp-inlayhints.nvim',
    enabled = rvim.lsp.enable,
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
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    enabled = rvim.lsp.enable,
    event = 'LspAttach',
    config = function() require('lsp_lines').setup() end,
  },
  -- }}}
  ----------------------------------------------------------------------------------------------------
  -- Utilities {{{1
  ----------------------------------------------------------------------------------------------------
  {
    'itchyny/vim-highlighturl',
    event = 'ColorScheme',
    config = function() vim.g.highlighturl_guifg = highlight.get('URL', 'fg') end,
  },
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
    'folke/flash.nvim',
    opts = {
      modes = {
        search = {
          search = { trigger = ';' },
        },
        char = {
          keys = { 'f', 'F', 't', 'T', ';' }, -- remove "," from keys
        },
      },
    },
    keys = {
      { 's', function() require('flash').jump() end, mode = { 'n', 'x', 'o' } },
      { 'S', function() require('flash').treesitter() end, mode = { 'o', 'x' } },
      { 'r', function() require('flash').remote() end, mode = 'o', desc = 'Remote Flash' },
    },
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
    enabled = rvim.treesitter.enable,
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
    enabled = rvim.lsp.enable,
    opts = {},
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
    enabled = not rvim.plugins.minimal,
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
    opts = {
      position = { relative_to = 'win', anchor = 'topright' },
      style = { border = 'single', hide_buffer_id = true },
    },
  },
  {
    'razak17/buffer_manager.nvim',
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      require('buffer_manager').setup({
        select_menu_item_commands = {
          v = { key = '<C-v>', command = 'vsplit' },
          h = { key = '<C-h>', command = 'split' },
        },
        borderchars = ui.border.common,
      })
      local bmui = require('buffer_manager.ui')
      local keys = '1234567890'
      for i = 1, #keys do
        local key = keys:sub(i, i)
        map('n', fmt('<leader>%s', key), function() bmui.nav_file(i) end, { noremap = true, desc = 'buffer ' .. key })
      end
      map({ 't', 'n' }, '<M-Space>', bmui.toggle_quick_menu, { noremap = true })
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
    enabled = not rvim.plugins.minimal,
    event = 'VimEnter',
    name = 'project_nvim',
    opts = {
      detection_methods = { 'pattern', 'lsp' },
      ignore_lsp = { 'null-ls' },
      patterns = { '.git' },
    },
  },
  {
    'razak17/lab.nvim',
    enabled = not rvim.plugins.minimal,
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
  {
    'razak17/rayso.nvim',
    cmd = { 'Rayso' },
    opts = {},
  },
  {
    'ellisonleao/carbon-now.nvim',
    cmd = 'CarbonNow',
    opts = {},
  },
  {
    'Sanix-Darker/snips.nvim',
    cmd = { 'SnipsCreate' },
    opts = {},
  },
  -- }}}
  ----------------------------------------------------------------------------------------------------
  -- Filetype Plugins {{{1
  ----------------------------------------------------------------------------------------------------
  { 'razak17/slides.nvim', ft = 'slide' },
  { 'fladson/vim-kitty', ft = 'kitty' },
  {
    'dmmulroy/tsc.nvim',
    enabled = rvim.lsp.enable,
    cmd = 'TSC',
    opts = {},
    ft = { 'typescript', 'typescriptreact' },
  },
  {
    'pmizio/typescript-tools.nvim',
    enabled = rvim.lsp.enable and not rvim.find_string(rvim.plugins.disabled, 'typescript-tools.nvim'),
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
  },
  {
    'razak17/tailwind-fold.nvim',
    enabled = rvim.treesitter.enable and not rvim.plugins.minimal,
    ft = { 'html', 'svelte', 'astro', 'vue', 'typescriptreact' },
    opts = { min_chars = 30 },
  },
  {
    'turbio/bracey.vim',
    enabled = not rvim.plugins.minimal,
    ft = 'html',
    build = 'npm install --prefix server',
  },
  {
    'olexsmir/gopher.nvim',
    enabled = not rvim.plugins.minimal,
    ft = 'go',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'iamcco/markdown-preview.nvim',
    enabled = not rvim.plugins.minimal,
    build = function() fn['mkdp#util#install']() end,
    ft = 'markdown',
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    'NTBBloodbath/rest.nvim',
    enabled = not rvim.plugins.minimal,
    ft = { 'http', 'json' },
    keys = {
      { '<localleader>rs', '<Plug>RestNvim', desc = 'rest: run', buffer = 0 },
      { '<localleader>rp', '<Plug>RestNvimPreview', desc = 'rest: preview', buffer = 0 },
      { '<localleader>rl', '<Plug>RestNvimLast', desc = 'rest: run last', buffer = 0 },
    },
    opts = { skip_ssl_verification = true },
  },
  {
    'razak17/package-info.nvim',
    enabled = not rvim.plugins.minimal,
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
    enabled = not rvim.plugins.minimal,
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
    enabled = not rvim.plugins.minimal,
    event = 'BufRead',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    opts = { remove_template_string = true },
  },
  {
    'marilari88/twoslash-queries.nvim',
    enabled = rvim.treesitter.enable and not rvim.plugins.minimal,
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
          if client.name == 'tsserver' then require('twoslash-queries').attach(client, args.buf) end
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
    enabled = not rvim.plugins.minimal,
    lazy = false,
    build = ':DirtytalkUpdate',
    init = function() vim.opt.spelllang:append('programming') end,
  },
  ---}}}
}
