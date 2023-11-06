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
  'b0o/schemastore.nvim',
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
    'mrjones2014/smart-splits.nvim',
    opts = {},
    build = './kitty/install-kittens.bash',
  },
  {
    'razak17/lspkind.nvim',
    config = function() require('lspkind').init({ preset = 'codicons' }) end,
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
  -- }}}
  ------------------------------------------------------------------------------
  -- LSP {{{1
  ------------------------------------------------------------------------------
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
    cond = rvim.lsp.enable and false,
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
    cond = rvim.lsp.enable and false,
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
      format = function(diagnostic)
        local disabled = { 'lazy' }
        for _, v in ipairs(disabled) do
          if vim.bo.ft == v then return '' end
        end
        return diagnostic.message
      end,
      padding_top = 2,
      toggle_event = { 'InsertEnter' },
    },
  },
  {
    'doums/dmap.nvim',
    cond = rvim.lsp.enable and false,
    event = 'LspAttach',
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
    cond = rvim.lsp.enable and false,
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
    cond = rvim.lsp.enable,
    opts = {},
    config = function()
      require('actions-preview').setup({
        telescope = rvim.telescope.vertical(),
      })
    end,
  },
  {
    'chrisgrieser/nvim-rulebook',
    cond = rvim.lsp.enable,
    keys = {
      {
        '<localleader>lri',
        function() require('rulebook').ignoreRule() end,
        desc = 'rulebook: ignore rule',
      },
      {
        '<localleader>lrl',
        function() require('rulebook').lookupRule() end,
        desc = 'rulebook: lookup rule',
      },
    },
  },
  {
    'luckasRanarison/clear-action.nvim',
    cond = rvim.lsp.enable,
    event = 'LspAttach',
    opts = {
      signs = {
        show_count = false,
        show_label = true,
        combine = true,
        icons = {
          combined = ui.icons.misc.lightbulb,
        },
        highlights = {
          combined = 'CodeActionIcon',
        },
      },
      popup = { border = border },
      mappings = {
        code_action = { '<leader><leader>la', 'code action' },
        apply_first = { '<leader><leader>aa', 'apply first' },
        quickfix = { '<leader><leader>aq', 'quickfix' },
        quickfix_next = { '<leader><leader>an', 'quickfix next' },
        quickfix_prev = { '<leader><leader>ap', 'quickfix prev' },
        refactor = { '<leader><leader>ar', 'refactor' },
        refactor_inline = { '<leader><leader>aR', 'refactor inline' },
        actions = {
          ['rust_analyzer'] = {
            ['Import'] = { '<leader><leader>ai', 'import' },
            ['Replace if'] = {
              '<leader><leader>am',
              'replace if with match',
            },
            ['Fill match'] = { '<leader><leader>af', 'fill match arms' },
            ['Wrap'] = { '<leader><leader>aw', 'Wrap' },
            ['Insert `mod'] = { '<leader><leader>aM', 'insert mod' },
            ['Insert `pub'] = { '<leader><leader>aP', 'insert pub mod' },
            ['Add braces'] = { '<leader><leader>ab', 'add braces' },
          },
        },
      },
      quickfix_filters = {
        ['rust_analyzer'] = {
          ['E0412'] = 'Import',
          ['E0425'] = 'Import',
          ['E0433'] = 'Import',
          ['unused_imports'] = 'remove',
        },
      },
    },
  },
  {
    'zeioth/garbage-day.nvim',
    cond = rvim.lsp.enable,
    event = 'BufEnter',
    opts = {
      grace_period = 60 * 15,
      notifications = true,
      excluded_languages = { 'java', 'markdown' },
    },
  },
  {
    'Wansmer/symbol-usage.nvim',
    cond = rvim.lsp.enable,
    event = 'LspAttach',
    config = function()
      highlight.plugin('symbol-usage', {
        theme = {
          ['onedark'] = {
            {
              SymbolUsageRounding = {
                italic = true,
                fg = { from = 'CursorLine', attr = 'bg' },
              },
            },
            {
              SymbolUsageContent = {
                italic = true,
                bg = { from = 'CursorLine' },
                fg = { from = 'Comment' },
              },
            },
            {
              SymbolUsageRef = {
                italic = true,
                bg = { from = 'CursorLine' },
                fg = { from = 'Function' },
              },
            },
            {
              SymbolUsageDef = {
                italic = true,
                bg = { from = 'CursorLine' },
                fg = { from = 'Type' },
              },
            },
            {
              SymbolUsageImpl = {
                italic = true,
                bg = { from = 'CursorLine' },
                fg = { from = '@keyword' },
              },
            },
            {
              SymbolUsageContent = {
                bold = false,
                italic = true,
                bg = { from = 'CursorLine' },
                fg = { from = 'Comment' },
              },
            },
          },
        },
      })

      local function text_format(symbol)
        local res = {}

        local round_start = { '', 'SymbolUsageRounding' }
        local round_end = { '', 'SymbolUsageRounding' }

        if symbol.references then
          local usage = symbol.references <= 1 and 'usage' or 'usages'
          local num = symbol.references == 0 and 'no' or symbol.references
          table.insert(res, round_start)
          table.insert(res, { '󰌹 ', 'SymbolUsageRef' })
          table.insert(
            res,
            { ('%s %s'):format(num, usage), 'SymbolUsageContent' }
          )
          table.insert(res, round_end)
        end

        if symbol.definition then
          if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
          table.insert(res, round_start)
          table.insert(res, { '󰳽 ', 'SymbolUsageDef' })
          table.insert(
            res,
            { symbol.definition .. ' defs', 'SymbolUsageContent' }
          )
          table.insert(res, round_end)
        end

        if symbol.implementation then
          if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
          table.insert(res, round_start)
          table.insert(res, { '󰡱 ', 'SymbolUsageImpl' })
          table.insert(
            res,
            { symbol.implementation .. ' impls', 'SymbolUsageContent' }
          )
          table.insert(res, round_end)
        end

        return res
      end

      require('symbol-usage').setup({
        text_format = text_format,
      })
    end,
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Utilities {{{1
  ------------------------------------------------------------------------------
  { 'sQVe/sort.nvim', cmd = { 'Sort' } },
  { 'lambdalisue/suda.vim', lazy = false },
  { 'will133/vim-dirdiff', cmd = { 'DirDiff' } },
  { 'godlygeek/tabular', cmd = { 'Tabularize' } },
  {
    'kevinhwang91/nvim-fundo',
    event = { 'BufRead', 'BufNewFile' },
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
    opts = { create_keymaps = false },
    config = function(opts)
      local svelte = {
        left = 'console.log("',
        right = '")',
        mid_var = '", ',
        right_var = ')',
      }
      local python = {
        left = 'print(f"',
        right = '"',
        mid_var = '{',
        right_var = '}"',
      }

      require('debugprint').setup(opts)
      require('debugprint').add_custom_filetypes({
        python = python,
        svelte = svelte,
      })
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff',
    keys = {
      { '<localleader>lL', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
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
    'AckslD/muren.nvim',
    cmd = { 'MurenToggle', 'MurenUnique', 'MurenFresh' },
    opts = {},
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
    '2kabhishek/nerdy.nvim',
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-telescope/telescope.nvim',
    },
    cmd = 'Nerdy',
  },
  -- Games
  --------------------------------------------------------------------------------
  {
    'ThePrimeagen/vim-be-good',
    cmd = 'VimBeGood',
  },
  {
    'NStefan002/speedtyper.nvim',
    cmd = 'Speedtyper',
    opts = {},
  },
  -- Share Code
  --------------------------------------------------------------------------------
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
  -- Regex
  --------------------------------------------------------------------------------
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
  -- }}}
}
