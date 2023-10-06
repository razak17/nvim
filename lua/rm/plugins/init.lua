local cmd, fn = vim.cmd, vim.fn
local fmt = string.format
local ui, highlight = rvim.ui, rvim.highlight
local border = ui.current.border

return {
  ------------------------------------------------------------------------------
  -- Core {{{3
  ------------------------------------------------------------------------------
  'nvim-lua/plenary.nvim',
  'nvim-tree/nvim-web-devicons',
  {
    'olimorris/persisted.nvim',
    cond = not rvim.plugins.minimal,
    lazy = false,
    init = function() rvim.command('ListSessions', 'Telescope persisted') end,
    opts = {
      use_git_branch = true,
      save_dir = fn.expand(vim.fn.stdpath('cache') .. '/sessions/'),
      ignored_dirs = { vim.fn.stdpath('data') },
      on_autoload_no_session = function() cmd.Alpha() end,
      should_autosave = function() return vim.bo.filetype ~= 'alpha' end,
    },
  },
  {
    'sindrets/winshift.nvim',
    cmd = { 'WinShift' },
    keys = {
      {
        '<leader>sw',
        '<Cmd>WinShift<CR>',
        desc = 'winshift: start winshift mode',
      },
      {
        '<leader>ss',
        '<Cmd>WinShift swap<CR>',
        desc = 'winshift: swap two window',
      },
      { '<leader>sh', '<Cmd>WinShift left<CR>', desc = 'winshift: swap left' },
      { '<leader>sj', '<Cmd>WinShift down<CR>', desc = 'winshift: swap down' },
      { '<leader>sk', '<Cmd>WinShift up<CR>', desc = 'winshift: swap up' },
      {
        '<leader>sl',
        '<Cmd>WinShift right<CR>',
        desc = 'winshift: swap right',
      },
    },
    opts = {},
  },
  {
    'mrjones2014/smart-splits.nvim',
    opts = {},
    build = './kitty/install-kittens.bash',
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Themes {{{1
  ------------------------------------------------------------------------------
  {
    'razak17/onedark.nvim',
    lazy = false,
    priority = 1000,
    opts = { variant = 'fill' },
    config = function(_, opts) require('onedark').setup(opts) end,
  },
  { 'LunarVim/horizon.nvim', lazy = false, priority = 1000 },
  { 'dotsilas/darcubox-nvim', lazy = false, priority = 1000 },
  { 'Wansmer/serenity.nvim', priority = 1000, opts = {} },
  { 'judaew/ronny.nvim', priority = 1000, opts = {} },
  -- }}}
  ------------------------------------------------------------------------------
  -- LSP,Completion & Debugger {{{1
  ------------------------------------------------------------------------------
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
        registries = {
          'lua:mason-registry.index',
          'github:mason-org/mason-registry',
        },
        providers = { 'mason.providers.registry-api', 'mason.providers.client' },
        ui = { border = border, height = 0.8 },
      },
    },
    {
      'williamboman/mason-lspconfig.nvim',
      cond = rvim.lsp.enable,
      event = { 'BufReadPre', 'BufNewFile' },
      opts = {
        automatic_installation = true,
        handlers = {
          function(name)
            local cwd = vim.fn.getcwd()
            if not rvim.falsy(rvim.lsp.override) then
              if not rvim.find_string(rvim.lsp.override, name) then return end
            else
              local directory_disabled =
                ---@diagnostic disable-next-line: param-type-mismatch
                rvim.dirs_match(rvim.lsp.disabled.directories, cwd)
              local server_disabled =
                rvim.find_string(rvim.lsp.disabled.servers, name)
              if directory_disabled or server_disabled then return end
            end
            local config = require('rm.servers')(name)
            if config then require('lspconfig')[name].setup(config) end
          end,
        },
      },
      dependencies = {
        'mason.nvim',
        {
          'neovim/nvim-lspconfig',
          cond = rvim.lsp.enable,
          config = function()
            require('lspconfig.ui.windows').default_options.border = border
          end,
          dependencies = {
            {
              'folke/neodev.nvim',
              cond = rvim.lsp.enable,
              ft = 'lua',
              opts = {
                debug = true,
                experimental = { pathStrict = true },
                library = {
                  runtime = join_paths(
                    vim.env.HOME,
                    'neovim',
                    'share',
                    'nvim',
                    'runtime'
                  ),
                  plugins = {},
                  types = true,
                },
              },
            },
            {
              'folke/neoconf.nvim',
              cond = rvim.lsp.enable,
              cmd = { 'Neoconf' },
              opts = {
                local_settings = '.nvim.json',
                global_settings = 'nvim.json',
              },
            },
          },
        },
      },
    },
  },
  {
    'glepnir/lspsaga.nvim',
    cond = rvim.lsp.enable,
    event = 'LspAttach',
    opts = {
      ui = { border = border },
      code_action = { show_server_name = true },
      lightbulb = { enable = false },
      symbol_in_winbar = { enable = false },
    },
    keys = {
      { '<leader>lo', '<cmd>Lspsaga outline<CR>', 'lspsaga: outline' },
      {
        '<localleader>lf',
        '<cmd>Lspsaga lsp_finder<cr>',
        desc = 'lspsaga: finder',
      },
      {
        '<localleader>la',
        '<cmd>Lspsaga code_action<cr>',
        desc = 'lspsaga: code action',
      },
      {
        '<M-p>',
        '<cmd>Lspsaga peek_type_definition<cr>',
        desc = 'lspsaga: type definition',
      },
      {
        '<M-i>',
        '<cmd>Lspsaga incoming_calls<cr>',
        desc = 'lspsaga: incoming calls',
      },
      {
        '<M-o>',
        '<cmd>Lspsaga outgoing_calls<cr>',
        desc = 'lspsaga: outgoing calls',
      },
    },
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    'smjonas/inc-rename.nvim',
    opts = { hl_group = 'Visual', preview_empty_name = true },
    keys = {
      {
        '<leader>rn',
        function() return fmt(':IncRename %s', fn.expand('<cword>')) end,
        expr = true,
        silent = false,
        desc = 'lsp: incremental rename',
      },
    },
  },
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    cond = rvim.lsp.enable,
    event = 'LspAttach',
    config = function() require('lsp_lines').setup() end,
  },
  {
    'kosayoda/nvim-lightbulb',
    cond = rvim.lsp.enable,
    event = 'LspAttach',
    opts = {
      autocmd = { enabled = true },
      sign = { enabled = false },
      virtual_text = {
        enabled = true,
        text = ui.icons.misc.lightbulb,
        hl_mode = 'blend',
      },
      float = {
        text = ui.icons.misc.lightbulb,
        enabled = false,
        win_opts = { border = 'none' },
      },
    },
  },
  {
    'dgagn/diagflow.nvim',
    cond = rvim.lsp.enable,
    event = 'LspAttach',
    opts = {
      padding_top = 2,
      toggle_event = { 'InsertEnter' },
    },
  },
  {
    'doums/dmap.nvim',
    cond = rvim.lsp.enable,
    -- event = 'LspAttach',
    opts = { win_h_offset = 6 },
  },
  {
    'stevearc/aerial.nvim',
    cond = not rvim.plugins.minimal and rvim.treesitter.enable,
    opts = {
      lazy_load = false,
      backends = {
        ['_'] = { 'treesitter', 'lsp', 'markdown', 'man' },
        elixir = { 'treesitter' },
        typescript = { 'treesitter' },
        typescriptreact = { 'treesitter' },
      },
      filter_kind = false,
      icons = {
        Field = ' 󰙅 ',
        Type = '󰊄 ',
      },
      treesitter = {
        experimental_selection_range = true,
      },
      k = 2,
      post_parse_symbol = function(bufnr, item, ctx)
        if
          ctx.backend_name == 'treesitter'
          and (ctx.lang == 'typescript' or ctx.lang == 'tsx')
        then
          local utils = require('nvim-treesitter.utils')
          local value_node = (utils.get_at_path(ctx.match, 'var_type') or {}).node
          -- don't want to display in-function items
          local cur_parent = value_node and value_node:parent()
          while cur_parent do
            if
              cur_parent:type() == 'arrow_function'
              or cur_parent:type() == 'function_declaration'
              or cur_parent:type() == 'method_definition'
            then
              return false
            end
            cur_parent = cur_parent:parent()
          end
        elseif
          ctx.backend_name == 'lsp'
          and ctx.symbol
          and ctx.symbol.location
          and string.match(ctx.symbol.location.uri, '%.graphql$')
        then
          -- for graphql it was easier to go with LSP. Use the symbol kind to keep only the toplevel queries/mutations
          return ctx.symbol.kind == 5
        elseif
          ctx.backend_name == 'treesitter'
          and ctx.lang == 'html'
          and vim.fn.expand('%:e') == 'ui'
        then
          -- in GTK UI files only display 'object' items (widgets), and display their
          -- class instead of the tag name (which is always 'object')
          if item.name == 'object' then
            local line = vim.api.nvim_buf_get_lines(
              bufnr,
              item.lnum - 1,
              item.lnum,
              false
            )[1]
            local _, _, class = string.find(line, [[class=.([^'"]+)]])
            item.name = class
            return true
          else
            return false
          end
        end
        return true
      end,
      get_highlight = function(symbol, _)
        if symbol.scope == 'private' then return 'AerialPrivate' end
      end,
    },
    config = function(_, opts)
      vim.api.nvim_set_hl(0, 'AerialPrivate', { default = true, italic = true })
      require('aerial').setup(opts)
      require('telescope').load_extension('aerial')
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    'roobert/action-hints.nvim',
    cond = false,
    event = 'LspAttach',
    config = function()
      require('action-hints').setup({
        template = {
          definition = { text = ' ⊛', color = '#add8e6' },
          references = { text = ' ↱%s', color = '#ff6666' },
        },
        use_virtual_text = true,
      })
    end,
  },
  {
    'aznhe21/actions-preview.nvim',
    opts = {},
    config = function()
      require('actions-preview').setup({
        telescope = rvim.telescope.vertical(),
      })
    end,
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Utilities {{{1
  ------------------------------------------------------------------------------
  { 'sQVe/sort.nvim', cmd = { 'Sort' } },
  { 'lambdalisue/suda.vim', lazy = false },
  { 'will133/vim-dirdiff', cmd = 'DirDiff' },
  { 'godlygeek/tabular', cmd = { 'Tabularize' } },
  {
    'itchyny/vim-highlighturl',
    event = 'ColorScheme',
    config = function() vim.g.highlighturl_guifg = highlight.get('URL', 'fg') end,
  },
  {
    'linux-cultist/venv-selector.nvim',
    cmd = 'VenvSelect',
    opts = {
      name = { 'venv', '.venv', 'env', '.env' },
    },
    keys = {
      { '<localleader>le', '<cmd>:VenvSelect<cr>', desc = 'Select VirtualEnv' },
    },
  },
  {
    'kevinhwang91/nvim-fundo',
    event = 'VeryLazy',
    build = function() require('fundo').install() end,
    dependencies = { 'kevinhwang91/promise-async' },
  },
  {
    'smoka7/multicursors.nvim',
    cond = not rvim.plugins.minimal and rvim.treesitter.enable,
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'smoka7/hydra.nvim' },
    opts = {
      hint_config = { border = border },
    },
    cmd = {
      'MCstart',
      'MCvisual',
      'MCclear',
      'MCpattern',
      'MCvisualPattern',
      'MCunderCursor',
    },
    keys = {
      {
        '<M-e>',
        '<cmd>MCstart<cr>',
        mode = { 'v', 'n' },
        desc = 'Create a selection for selected text or word under the cursor',
      },
    },
  },
  {
    'folke/flash.nvim',
    opts = {
      modes = {
        char = {
          keys = { 'f', 'F', 't', 'T', ';' }, -- remove "," from keys
        },
      },
    },
    keys = {
      { 's', function() require('flash').jump() end, mode = { 'n', 'x', 'o' } },
      {
        'S',
        function() require('flash').treesitter() end,
        mode = { 'o', 'x' },
      },
      {
        'r',
        function() require('flash').remote() end,
        mode = 'o',
        desc = 'Remote Flash',
      },
      {
        '<c-s>',
        function() require('flash').toggle() end,
        mode = { 'c' },
        desc = 'Toggle Flash Search',
      },
      {
        'R',
        function() require('flash').treesitter_search() end,
        mode = { 'o', 'x' },
        desc = 'Flash Treesitter Search',
      },
    },
  },
  {
    'folke/twilight.nvim',
    cond = rvim.treesitter.enable,
    cmd = 'Twilight',
    opts = {
      context = 40,
      dimming = { alpha = 0.45, inactive = true },
      exclude = { 'alpha', 'git' },
    },
  },
  {
    'andrewferrier/debugprint.nvim',
    cond = rvim.treesitter.enable,
    keys = {
      {
        '<leader>pp',
        function() return require('debugprint').debugprint({ variable = true }) end,
        expr = true,
        desc = 'debugprint: cursor',
      },
      {
        '<leader>pP',
        function()
          return require('debugprint').debugprint({
            above = true,
            variable = true,
          })
        end,
        expr = true,
        desc = 'debugprint: cursor (above)',
      },
      {
        '<leader>pi',
        function()
          return require('debugprint').debugprint({
            ignore_treesitter = true,
            variable = true,
          })
        end,
        expr = true,
        desc = 'debugprint: prompt',
      },
      {
        '<leader>pI',
        function()
          return require('debugprint').debugprint({
            ignore_treesitter = true,
            above = true,
            variable = true,
          })
        end,
        expr = true,
        desc = 'debugprint:prompt (above)',
      },
      {
        '<leader>po',
        function() return require('debugprint').debugprint({ motion = true }) end,
        expr = true,
        desc = 'debugprint: operator',
      },
      {
        '<leader>pO',
        function()
          return require('debugprint').debugprint({
            above = true,
            motion = true,
          })
        end,
        expr = true,
        desc = 'debugprint: operator (above)',
      },
      {
        '<leader>px',
        '<Cmd>DeleteDebugPrints<CR>',
        desc = 'debugprint: clear all',
      },
    },
    opts = {
      create_keymaps = false,
      filetypes = {
        svelte = {
          left = 'console.log("',
          right = '")',
          mid_var = '", ',
          right_var = ')',
        },
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'chrisgrieser/nvim-origami',
    event = 'BufReadPost',
    keys = {
      { '<BS>', function() require('origami').h() end, desc = 'toggle fold' },
    },
    opts = { setupFoldKeymaps = false },
  },
  {
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff',
    keys = {
      { '<localleader>lL', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
    },
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local autopairs = require('nvim-autopairs')
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
      autopairs.setup({
        close_triple_quotes = true,
        disable_filetype = { 'neo-tree-popup' },
        check_ts = true,
        fast_wrap = { map = '<c-e>' },
        ts_config = {
          lua = { 'string' },
          dart = { 'string' },
          javascript = { 'template_string' },
        },
      })
    end,
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
    cond = false,
    priority = 1001,
    opts = {
      window = { open = 'tab' },
      block_for = {
        gitcommit = true,
        gitrebase = true,
      },
      post_open = function(bufnr, winnr, _, is_blocking)
        vim.w[winnr].is_remote = true
        if is_blocking then
          vim.bo.bufhidden = 'wipe'
          vim.api.nvim_create_autocmd('BufHidden', {
            desc = 'Close window when buffer is hidden',
            callback = function()
              if vim.api.nvim_win_is_valid(winnr) then
                vim.api.nvim_win_close(winnr, true)
              end
            end,
            buffer = bufnr,
            once = true,
          })
        end
      end,
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
          markdown = 'glow %',
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
    'google/executor.nvim',
    keys = {
      { '<localleader>xc', '<cmd>ExecutorRun<CR>', desc = 'executor: start' },
      {
        '<localleader>xs',
        '<cmd>ExecutorSetCommand<CR>',
        desc = 'executor: set command',
      },
      {
        '<localleader>xd',
        '<cmd>ExecutorToggleDetail<CR>',
        desc = 'executor: toggle detail',
      },
      {
        '<localleader>xr',
        '<cmd>ExecutorReset<CR>',
        desc = 'executor: reset status',
      },
      {
        '<localleader>xp',
        '<cmd>ExecutorShowPresets<CR>',
        desc = 'executor: show presets',
      },
    },
    opts = {
      input = {
        border = {
          style = 'single',
          padding = {
            top = 1,
            bottom = 1,
            left = 1,
            right = 1,
          },
        },
      },
      notifications = {
        task_started = true,
        task_completed = true,
      },
      preset_commands = {
        ['custom-website'] = {
          'npm run dev',
        },
      },
    },
  },
  {
    'ThePrimeagen/vim-be-good',
    cmd = 'VimBeGood',
  },
  {
    'ahmedkhalf/project.nvim',
    cond = not rvim.plugins.minimal,
    event = 'VimEnter',
    name = 'project_nvim',
    opts = {
      detection_methods = { 'pattern', 'lsp' },
      ignore_lsp = { 'null-ls' },
      patterns = { '.git' },
    },
  },
  {
    'chrisgrieser/nvim-genghis',
    dependencies = 'stevearc/dressing.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local g = require('genghis')
      map(
        'n',
        '<localleader>fp',
        g.copyFilepath,
        { desc = 'genghis: yank filepath' }
      )
      map(
        'n',
        '<localleader>fn',
        g.copyFilename,
        { desc = 'genghis: yank filename' }
      )
      map(
        'n',
        '<localleader>fr',
        g.renameFile,
        { desc = 'genghis: rename file' }
      )
      map(
        'n',
        '<localleader>fm',
        g.moveAndRenameFile,
        { desc = 'genghis: move and rename' }
      )
      map(
        'n',
        '<localleader>fc',
        g.createNewFile,
        { desc = 'genghis: create new file' }
      )
      map(
        'n',
        '<localleader>fd',
        g.duplicateFile,
        { desc = 'genghis: duplicate current file' }
      )
    end,
  },
  {
    'michaelb/sniprun',
    build = 'sh install.sh',
    cmd = { 'SnipRun', 'SnipInfo' },
    keys = {
      {
        mode = 'v',
        '<localleader>rr',
        ':SnipRun<CR>',
        desc = 'sniprun: run code',
      },
      { '<localleader>rr', ':SnipRun<CR>', desc = 'sniprun: run code' },
      { '<localleader>ri', ':SnipInfo<CR>', desc = 'sniprun: info' },
      { '<localleader>rc', ':SnipReset<CR>', desc = 'sniprun: reset' },
      { '<localleader>rq', ':SnipClose<CR>', desc = 'sniprun: close' },
    },
    opts = {},
    config = function(_, opts)
      highlight.plugin('lab', {
        theme = {
          ['onedark'] = {
            { SniprunVirtualTextOk = { link = 'DiagnosticVirtualTextInfo' } },
            { SniprunFloatingWinOk = { link = 'DiagnosticVirtualTextInfo' } },
            { SniprunVirtualTextErr = { link = 'DiffDelete' } },
            { SniprunFloatingWinErr = { link = 'DiffDelete' } },
          },
        },
      })
      require('sniprun').setup(opts)
    end,
  },
  {
    'razak17/lab.nvim',
    cond = not rvim.plugins.minimal,
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
          ['onedark'] = {
            { LabCodeRun = { link = 'DiagnosticVirtualTextInfo' } },
          },
        },
      })
      require('lab').setup()
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'TobinPalmer/rayso.nvim',
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
  {
    'AckslD/muren.nvim',
    cmd = { 'MurenToggle', 'MurenUnique', 'MurenFresh' },
    opts = {},
  },
  {
    'llllvvuu/nvim-js-actions',
    cond = rvim.treesitter.enable,
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'jpalardy/vim-slime',
    event = 'VeryLazy',
    keys = {
      {
        '<localleader>st',
        '<Plug>SlimeParagraphSend',
        desc = 'slime: paragraph',
      },
      {
        '<localleader>st',
        '<Plug>SlimeRegionSend',
        mode = { 'x' },
        desc = 'slime: region',
      },
      { '<localleader>sc', '<Plug>SlimeConfig', desc = 'slime: config' },
    },
    config = function()
      vim.g.slime_target = 'tmux'
      vim.g.slime_paste_file = vim.fn.stdpath('data') .. '/.slime_paste'
      vim.g.alime_no_mappings = 1
    end,
  },
  {
    'luckasRanarison/nvim-devdocs',
    cond = not rvim.plugins.minimal,
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      {
        '<localleader>vf',
        '<cmd>DevdocsOpenFloat<CR>',
        desc = 'devdocs: open float',
      },
      {
        '<localleader>vb',
        '<cmd>DevdocsOpen<CR>',
        desc = 'devdocs: open in buffer',
      },
      {
        '<localleader>vo',
        ':DevdocsOpenFloat ',
        desc = 'devdocs: open documentation',
      },
      { '<localleader>vi', ':DevdocsInstall ', desc = 'devdocs: install' },
      { '<localleader>vu', ':DevdocsUninstall ', desc = 'devdocs: uninstall' },
    },
    opts = {
      ensure_installed = {
        'git',
        'bash',
        'lua-5.4',
        'html',
        'css',
        'javascript',
        'typescript',
        'react',
        'svelte',
        'web_extensions',
        'postgresql-15',
        'python-3.11',
        'go',
        'docker',
        'tailwindcss',
        'astro',
      },
      wrap = true,
    },
  },
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
      'kristijanhusak/vim-dadbod-completion',
    },
    keys = {
      { '<leader>dt', '<Cmd>DBUIToggle<CR>', desc = 'dadbod: toggle' },
      {
        '<leader>da',
        '<Cmd>DBUIAddConnection<CR>',
        desc = 'dadbod: add connection',
      },
    },
    cmd = {
      'DBUI',
      'DBUIAddConnection',
      'DBUIClose',
      'DBUIToggle',
      'DBUIFindBuffer',
      'DBUIRenameBuffer',
      'DBUILastQueryInfo',
    },
    config = function()
      vim.g.db_ui_notification_width = 1
      vim.g.db_ui_debug = 1
    end,
  },
  {
    'NStefan002/speedtyper.nvim',
    cmd = 'Speedtyper',
    opts = {},
  },
  {
    'potamides/pantran.nvim',
    keys = {
      {
        '<leader><leader>tm',
        function() return require('pantran').motion_translate() end,
        mode = { 'n', 'x' },
        expr = true,
        desc = 'motion',
      },
      {
        '<leader><leader>tp',
        '<cmd>Pantran<CR>',
        mode = { 'n', 'v' },
        desc = 'prompt',
      },
    },
    config = function()
      rvim.highlight.plugin('pantran', {
        { PantranBorder = { inherit = 'FloatBorder' } },
      })

      local default_source = 'auto'
      local default_target = 'es'
      require('pantran').setup({
        default_engine = 'argos',
        engines = {
          argos = {
            default_source = default_source,
            default_target = default_target,
          },
          apertium = {
            default_source = default_source,
            default_target = default_target,
          },
          yandex = {
            default_source = default_source,
            default_target = default_target,
          },
          google = {
            default_source = default_source,
            default_target = default_target,
          },
        },
      })
    end,
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Filetype Plugins {{{1
  ------------------------------------------------------------------------------
  { 'razak17/slides.nvim', ft = 'slide' },
  { 'fladson/vim-kitty', ft = 'kitty' },
  { 'raimon49/requirements.txt.vim', lazy = false },
  { 'gennaro-tedesco/nvim-jqx', ft = { 'json', 'yaml' } },
  {
    'AckslD/nvim-FeMaco.lua',
    cmd = { 'FeMaco' },
    opts = {
      float_opts = function(code_block)
        local clip_val = require('femaco.utils').clip_val
        return {
          relative = 'cursor',
          width = clip_val(5, 120, vim.api.nvim_win_get_width(0) - 10),
          height = clip_val(
            5,
            #code_block.lines,
            vim.api.nvim_win_get_height(0) - 6
          ),
          anchor = 'NW',
          row = 0,
          col = 0,
          style = 'minimal',
          border = ui.current.border,
          zindex = 1,
        }
      end,
    },
  },
  {
    'whatyouhide/vim-lengthmatters',
    lazy = false,
    config = function()
      vim.g.lengthmatters_excluded = { 'packer' }
      vim.g.lengthmatters_linked_to = 'CursorLine'
    end,
  },
  {
    'laytan/cloak.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'dmmulroy/tsc.nvim',
    cond = rvim.lsp.enable,
    cmd = 'TSC',
    opts = {},
    ft = { 'typescript', 'typescriptreact' },
  },
  {
    'pmizio/typescript-tools.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    cond = rvim.lsp.enable
      and not rvim.find_string(rvim.plugins.disabled, 'typescript-tools.nvim'),
    dependencies = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
      'davidosomething/format-ts-errors.nvim',
    },
    opts = {
      settings = {
        tsserver_file_preferences = {
          includeInlayParameterNameHints = 'literal',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      handlers = {
        ['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
          if result.diagnostics == nil then return end

          -- ignore some tsserver diagnostics
          local idx = 1
          while idx <= #result.diagnostics do
            local entry = result.diagnostics[idx]

            local formatter = require('format-ts-errors')[entry.code]
            entry.message = formatter and formatter(entry.message)
              or entry.message

            -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
            if entry.code == 80001 then
              -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
              table.remove(result.diagnostics, idx)
            else
              idx = idx + 1
            end
          end

          vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
        end,
      },
    },
  },
  {
    'simrat39/rust-tools.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    cond = rvim.lsp.enable
      and not rvim.find_string(rvim.plugins.disabled, 'rust-tools.nvim'),
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      local rt = require('rust-tools')
      local mason_registry = require('mason-registry')

      local codelldb = mason_registry.get_package('codelldb')
      local extension_path = codelldb:get_install_path() .. '/extension'
      local codelldb_path = extension_path .. '/adapter/codelldb'
      local liblldb_path = extension_path .. '/lldb/lib/liblldb.so'

      require('which-key').register({
        ['<localleader>r'] = { name = 'Rust Tools', h = 'Inlay Hints' },
      })

      rt.setup({
        tools = {
          executor = require('rust-tools/executors').termopen, -- can be quickfix or termopen
          reload_workspace_from_cargo_toml = true,
          runnables = { use_telescope = false },
          inlay_hints = {
            auto = false,
            show_parameter_hints = false,
            parameter_hints_prefix = ' ',
          },
          hover_actions = {
            border = rvim.ui.border.rectangle,
            auto_focus = true,
            max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
            max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
          },
          on_initialized = function()
            vim.api.nvim_create_autocmd(
              { 'BufWritePost', 'BufEnter', 'CursorHold', 'InsertLeave' },
              {
                pattern = { '*.rs' },
                callback = function()
                  local _, _ = pcall(vim.lsp.codelens.refresh)
                end,
              }
            )
          end,
        },
        dap = {
          adapter = require('rust-tools.dap').get_codelldb_adapter(
            codelldb_path,
            liblldb_path
          ),
        },
        server = {
          on_attach = function(_, bufnr)
            map(
              'n',
              'K',
              rt.hover_actions.hover_actions,
              { desc = 'hover', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>rhe',
              rt.inlay_hints.set,
              { desc = 'set hints', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>rhd',
              rt.inlay_hints.unset,
              { desc = 'unset hints', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>rr',
              rt.runnables.runnables,
              { desc = 'runnables', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>rc',
              rt.open_cargo_toml.open_cargo_toml,
              { desc = 'open cargo', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>rd',
              rt.debuggables.debuggables,
              { desc = 'debuggables', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>rm',
              rt.expand_macro.expand_macro,
              { desc = 'expand macro', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>ro',
              rt.external_docs.open_external_docs,
              { desc = 'open external docs', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>rp',
              rt.parent_module.parent_module,
              { desc = 'parent module', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>rs',
              rt.workspace_refresh.reload_workspace,
              { desc = 'reload workspace', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>rg',
              '<Cmd>RustViewCrateGraph<CR>',
              { desc = 'view crate graph', buffer = bufnr }
            )
            map(
              'n',
              '<localleader>ra',
              rt.code_action_group.code_action_group,
              { desc = 'code action', buffer = bufnr }
            )
          end,
          standalone = false,
          settings = {
            ['rust-analyzer'] = {
              lens = { enable = true },
              checkOnSave = { enable = true, command = 'clippy' },
            },
          },
        },
      })
    end,
  },
  {
    'razak17/tailwind-fold.nvim',
    cond = false,
    opts = { min_chars = 2 },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { 'html', 'svelte', 'astro', 'vue', 'typescriptreact' },
  },
  {
    'MaximilianLloyd/tw-values.nvim',
    cond = rvim.treesitter.enable and rvim.lsp.enable,
    keys = {
      {
        '<localleader>lt',
        '<cmd>TWValues<cr>',
        desc = 'tw-values: show values',
      },
    },
    opts = { border = border, show_unknown_classes = true },
  },
  {
    'turbio/bracey.vim',
    cond = not rvim.plugins.minimal,
    ft = 'html',
    build = 'npm install --prefix server',
  },
  {
    'olexsmir/gopher.nvim',
    cond = rvim.lsp.enable and not rvim.plugins.minimal,
    ft = 'go',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    'ellisonleao/glow.nvim',
    cond = not rvim.plugins.minimal,
    cmd = 'Glow',
    ft = 'markdown',
    opts = {
      border = 'single',
      width = 120,
    },
  },
  {
    'razak17/md-headers.nvim',
    ft = 'markdown',
    cmd = { 'MarkdownHeaders', 'MarkdownHeadersClosest' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      {
        '<leader>mdh',
        '<cmd>MarkdownHeaders<CR>',
        desc = 'md-header: headers',
      },
      {
        '<leader>mdc',
        '<cmd>MarkdownHeadersClosest<CR>',
        desc = 'md-header: closest',
      },
    },
    opts = { borderchars = ui.border.common },
  },
  {
    'iamcco/markdown-preview.nvim',
    cond = not rvim.plugins.minimal,
    build = function() fn['mkdp#util#install']() end,
    ft = 'markdown',
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    'NTBBloodbath/rest.nvim',
    cond = not rvim.plugins.minimal,
    ft = { 'http', 'json' },
    keys = {
      { '<localleader>rs', '<Plug>RestNvim', desc = 'rest: run', buffer = 0 },
      {
        '<localleader>rp',
        '<Plug>RestNvimPreview',
        desc = 'rest: preview',
        buffer = 0,
      },
      {
        '<localleader>rl',
        '<Plug>RestNvimLast',
        desc = 'rest: run last',
        buffer = 0,
      },
    },
    opts = { skip_ssl_verification = true },
  },
  {
    'razak17/package-info.nvim',
    cond = not rvim.plugins.minimal,
    event = 'BufRead package.json',
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      highlight.plugin('package-info', {
        theme = {
          ['onedark'] = {
            {
              PackageInfoUpToDateVersion = {
                link = 'DiagnosticVirtualTextInfo',
              },
            },
            {
              PackageInfoOutdatedVersion = {
                link = 'DiagnosticVirtualTextWarn',
              },
            },
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
    cond = not rvim.plugins.minimal,
    event = 'BufRead Cargo.toml',
    opts = {
      popup = { autofocus = true, border = border },
      null_ls = { enabled = true, name = 'crates' },
    },
  },
  {
    'bennypowers/template-literal-comments.nvim',
    cond = rvim.treesitter.enable,
    ft = { 'javascript', 'typescript' },
    opts = {},
  },
  {
    'bennypowers/nvim-regexplainer',
    keys = {
      {
        '<localleader>rx',
        '<Cmd>RegexplainerToggle<CR>',
        desc = 'regexplainer: toggle',
      },
    },
    opts = {
      display = 'popup',
      popup = {
        border = {
          padding = { 1, 2 },
          style = border,
        },
      },
    },
  },
  {
    'tomiis4/Hypersonic.nvim',
    event = 'CmdlineEnter',
    cmd = 'Hypersonic',
    keys = {
      {
        mode = 'v',
        '<localleader>rx',
        '<Cmd>Hypersonic<CR>',
        desc = 'hypersonic: toggle',
      },
    },
    opts = { border = border },
  },
  {
    'axelvc/template-string.nvim',
    cond = rvim.treesitter.enable,
    event = 'BufRead',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'svelte',
    },
    opts = { remove_template_string = true },
  },
  {
    'roobert/f-string-toggle.nvim',
    cond = rvim.treesitter.enable,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { 'python' },
    opts = {},
  },
  {
    'marilari88/twoslash-queries.nvim',
    cond = rvim.treesitter.enable,
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      highlight.plugin('twoslash-queries', {
        theme = {
          ['onedark'] = {
            { TypeVirtualText = { link = 'DiagnosticVirtualTextInfo' } },
          },
        },
      })
    end,
  },
  {
    'nfrid/markdown-togglecheck',
    ft = { 'markdown' },
    keys = {
      {
        '<leader>ol',
        function() require('markdown-togglecheck').toggle() end,
        desc = 'toggle markdown checkbox',
      },
    },
    dependencies = { 'nfrid/treesitter-utils' },
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Syntax {{{1
  ------------------------------------------------------------------------------
  {
    'psliwka/vim-dirtytalk',
    cond = not rvim.plugins.minimal,
    lazy = false,
    build = ':DirtytalkUpdate',
    init = function() vim.opt.spelllang:append('programming') end,
  },
  ---}}}
}
