local fn = vim.fn
local cwd = fn.getcwd()
local fmt = string.format
local ui, highlight = ar.ui, ar.highlight
local icons, codicons = ar.ui.icons, ar.ui.codicons
local falsy, find_string = ar.falsy, ar.find_string
local border = ui.current.border
local lsp_icons = codicons.lsp
local detour = ar.reqidx('detour')
local features = ar.reqidx('detour.features')
local minimal = ar.plugins.minimal
local virtual_lines_variant = ar_config.lsp.virtual_lines.variant

return {
  ------------------------------------------------------------------------------
  -- LSP {{{1
  ------------------------------------------------------------------------------
  {
    {
      'mason-org/mason.nvim',
      cond = not minimal,
      event = { 'BufReadPre', 'BufNewFile' },
      keys = { { '<leader>lm', '<cmd>Mason<CR>', desc = 'mason info' } },
      build = ':MasonUpdate',
      init = function()
        ar.add_to_select_menu('command_palette', {
          ['Update All Mason Packages'] = 'MasonUpdateAll',
        })
      end,
      cmd = {
        'Mason',
        'MasonInstall',
        'MasonUninstall',
        'MasonUninstallAll',
        'MasonLog',
        'MasonUpdate',
        'MasonUpdateAll', -- this cmd is provided by mason-extra-cmds
      },
      opts = {
        ui = {
          border = border,
          height = 0.8,
          icons = {
            package_pending = ' ',
            package_installed = '󰄳 ',
            package_uninstalled = ' 󰚌',
          },
        },
        registries = {
          'lua:mason-registry.index',
          'github:mason-org/mason-registry',
          'github:nvim-java/mason-registry',
        },
        providers = { 'mason.providers.registry-api', 'mason.providers.client' },
      },
      dependencies = { 'Zeioth/mason-extra-cmds', opts = {} },
    },
    {
      'williamboman/mason-lspconfig.nvim',
      cond = ar.lsp.enable,
      event = { 'BufReadPre', 'BufNewFile' },
      opts = {
        automatic_enable = false,
        handlers = {
          function(name)
            local is_override = not falsy(ar_config.lsp.override)
              and not find_string(ar_config.lsp.override, name)
            local directory_disabled =
              ar.dirs_match(ar_config.lsp.disabled.directories, fmt('%s', cwd))

            local ts_lang = ar_config.lsp.lang.typescript

            local ts_ls = ts_lang == 'ts_ls'
            local vtsls = ts_lang == 'vtsls'
            local ts_tools = (name == 'ts_ls' or name == 'vtsls')
              and ts_lang == 'typescript-tools'

            local should_skip = is_override
              or directory_disabled
              or ar.lsp_disabled(name)
              or ts_tools
              or (name == 'vtsls' and not vtsls)
              or (name == 'ts_ls' and not ts_ls)

            local use_legacy_config = { 'graphql' }

            if should_skip then return end
            local config = require('ar.servers').get(name)
            if config then
              if vim.tbl_contains(use_legacy_config, name) then
                require('lspconfig')[name].setup(config)
              else
                vim.lsp.config(name, config)
                vim.lsp.enable(name)
              end
            end
          end,
        },
      },
      dependencies = {
        {
          'neovim/nvim-lspconfig',
          cond = ar.lsp.enable,
          config = function()
            require('lspconfig.ui.windows').default_options.border = border
            if ar_config.lsp.semantic_tokens.enable then
              local lspconfig = require('lspconfig')
              lspconfig.util.default_config =
                vim.tbl_extend('force', lspconfig.util.default_config, {
                  on_attach = function(client)
                    client.server_capabilities.semanticTokensProvider = nil
                  end,
                })
            end
          end,
          dependencies = {
            {
              'folke/lazydev.nvim',
              ft = 'lua',
              cmd = 'LazyDev',
              opts = {
                library = {
                  'lazy.nvim',
                  { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
                },
              },
            },
            {
              'folke/neoconf.nvim',
              cond = ar.lsp.enable,
              cmd = { 'Neoconf' },
              opts = {
                local_settings = '.nvim.json',
                global_settings = 'nvim.json',
              },
            },
          },
        },
        {
          'nvim-java/nvim-java',
          cond = false,
          ft = { 'java' },
          dependencies = {
            'nvim-java/lua-async-await',
            'nvim-java/nvim-java-core',
            'nvim-java/nvim-java-test',
            'nvim-java/nvim-java-dap',
            'MunifTanjim/nui.nvim',
            'neovim/nvim-lspconfig',
            'mfussenegger/nvim-dap',
          },
          config = function() require('java').setup({}) end,
        },
      },
    },
  },
  {
    'smjonas/inc-rename.nvim',
    cond = ar.lsp.enable,
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
    -- 'ErichDonGubler/lsp_lines.nvim',
    cond = ar.lsp.enable and virtual_lines_variant == 'lsp_lines',
    event = 'LspAttach',
    config = function() require('lsp_lines').setup() end,
  },
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    cond = not ar_config.lsp.virtual_text.enable
      and ar.lsp.enable
      and virtual_lines_variant == 'tiny-inline',
    event = 'LspAttach',
    priority = 1000,
    opts = {
      preset = 'modern', -- Can be: "modern", "classic", "minimal", "powerline", ghost", "simple", "nonerdfont", "amongus"
      transparent_bg = ar_config.ui.transparent.enable,
      options = {
        break_line = {
          enabled = true,
          after = 30,
        },
      },
    },
  },
  {
    -- 'razak17/glance.nvim',
    'dnlhc/glance.nvim',
    cond = ar.lsp.enable,
    -- stylua: ignore
    -- keys = {
    --   { 'gD', '<Cmd>Glance definitions<CR>', desc = 'lsp: glance definitions' },
    --   { 'gR', '<Cmd>Glance references<CR>', desc = 'lsp: glance references' },
    --   { 'gY', '<Cmd>Glance type_definitions<CR>', desc = 'lsp: glance type definitions' },
    --   { 'gM', '<Cmd>Glance implementations<CR>', desc = 'lsp: glance implementations' },
    -- },
    config = function()
      require('glance').setup({
        preview_win_opts = { relativenumber = false },
      })

      highlight.plugin('glance', {
        theme = {
          ['onedark'] = {
            { GlancePreviewNormal = { link = 'NormalFloat' } },
            -- { GlancePreviewMatch = { link = 'Comment' } },
            { GlanceListMatch = { link = 'Search' } },
          },
        },
      })
    end,
  },
  {
    'cseickel/diagnostic-window.nvim',
    cond = ar.lsp.enable and ar.plugins.niceties,
    event = 'LspAttach',
    cmd = { 'DiagWindowShow' },
    keys = {
      { 'gL', '<Cmd>DiagWindowShow<CR>', desc = 'diagnostic window: show' },
    },
    dependencies = { 'MunifTanjim/nui.nvim' },
  },
  {
    'dgagn/diagflow.nvim',
    cond = ar.lsp.enable and ar.plugins.niceties,
    event = 'LspAttach',
    opts = {
      format = function(diagnostic)
        local disabled = { 'lazy' }
        for _, v in ipairs(disabled) do
          if vim.bo.ft == v then return '' end
        end
        return diagnostic.message
      end,
      padding_top = 0,
      toggle_event = { 'InsertEnter' },
    },
  },
  {
    'icholy/lsplinks.nvim',
    event = 'LspAttach',
    cond = ar.lsp.enable,
    opts = {},
  },
  {
    'oskarrrrrrr/symbols.nvim',
    cond = not minimal,
    cmd = { 'Symbols', 'SymbolsClose' },
    config = function()
      local r = require('symbols.recipes')
      require('symbols').setup(r.DefaultFilters, r.AsciiSymbols, {
        sidebar = { open_direction = 'right' },
      })
    end,
  },
  {
    'stevearc/aerial.nvim',
    cmd = { 'AerialToggle' },
    cond = not minimal and ar.ts_extra_enabled and false,
    init = function()
      ar.add_to_select_menu('toggle', { ['Toggle Aerial'] = 'AerialToggle' })
    end,
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
  },
  {
    'razak17/hierarchy.nvim',
    init = function()
      ar.add_to_select_menu('lsp', {
        ['Function References'] = 'FuncReferences',
      })
    end,
    cond = ar.lsp.enable,
    opts = {},
  },
  {
    'rmagatti/goto-preview',
    cond = ar.lsp.enable,
    -- stylua: ignore
    keys = {
      { 'gpd', '<Cmd>lua require("goto-preview").goto_preview_definition()<CR>', desc = 'goto preview: definition' },
      { 'gpt', '<Cmd>lua require("goto-preview").goto_preview_type_definition()<CR>', desc = 'goto preview: type definition' },
      { 'gpi', '<Cmd>lua require("goto-preview").goto_preview_implementation()<CR>', desc = 'goto preview: implementation' },
      { 'gpD', '<Cmd>lua require("goto-preview").goto_preview_declaration()<CR>', desc = 'goto preview: declaration' },
      { 'gpr', '<Cmd>lua require("goto-preview").goto_preview_references()<CR>', desc = 'goto preview: references' },
      { 'gpx', '<Cmd>lua require("goto-preview").close_all_win()<CR>', desc = 'goto preview: close all windows' },
      { 'gpo', '<Cmd>lua require("goto-preview").close_all_win({ skip_curr_window = true })<CR>', desc = 'goto preview: close other windows' },
    },
    event = 'LspAttach',
    opts = {},
    dependencies = { 'rmagatti/logger.nvim' },
  },
  {
    'chrisgrieser/nvim-rulebook',
    cond = ar.lsp.enable,
    init = function()
      vim.g.whichkey_add_spec({ '<leader>l?', group = 'Rulebook' })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>l?f', function() require('rulebook').suppressFormatter() end, mode = { 'n', 'x' }, desc = 'rulebook: formatter suppress' },
      { '<leader>l?i', function() require('rulebook').ignoreRule() end, desc = 'rulebook: ignore rule' },
      { '<leader>l?l', function() require('rulebook').lookupRule() end, desc = 'rulebook: lookup rule' },
      { '<leader>l?y', function() require('rulebook').yankDiagnosticCode() end, desc = 'rulebook: yank diagnostic code' },
    },
    opts = {
      suppressFormatter = {
        -- use `biome` instead of `prettier`
        javascript = {
          location = 'prevLine',
          ignoreBlock = '// biome-ignore format: expl',
        },
        typescript = {
          location = 'prevLine',
          ignoreBlock = '// biome-ignore format: expl',
        },
        css = {
          location = 'prevLine',
          ignoreBlock = '/* biome-ignore format: expl */',
        },
      },
    },
  },
  {
    'zeioth/garbage-day.nvim',
    cond = ar.lsp.enable and ar_config.plugins.overrides.garbage_day.enable,
    event = 'LspAttach',
    opts = {
      grace_period = 60 * 15,
      notifications = true,
      excluded_languages = { 'java', 'markdown' },
    },
  },
  {
    'stevanmilic/nvim-lspimport',
    cond = ar.lsp.enable,
    ft = { 'python' },
    -- stylua: ignore
    keys = {
      { '<localleader>ll', function() require('lspimport').import() end, desc = 'lsp-import: import (python)' },
    },
  },
  {
    'antosha417/nvim-lsp-file-operations',
    cond = ar.lsp.enable,
    event = 'LspAttach',
    opts = {},
  },
  {
    'pechorin/any-jump.vim',
    cond = ar.lsp.enable,
    cmd = { 'AnyJump', 'AnyJumpArg', 'AnyJumpBack', 'AnyJumpLastResults' },
    init = function()
      vim.g.any_jump_disable_default_keybindings = 1
      vim.g.whichkey_add_spec({ '<leader>j', group = 'Any Jump' })
      ar.add_to_select_menu('lsp', {
        ['Jump To Keyword'] = function()
          vim.ui.input({
            prompt = 'Keyword: ',
            default = '',
            completion = 'keyword',
          }, function(keyword)
            if not keyword or keyword == '' then return end
            vim.cmd(fmt('AnyJumpArg %s', keyword))
          end)
        end,
      })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>jj', '<Cmd>AnyJump<CR>', desc = 'any-jump: jump' },
      { mode = { 'x' }, '<leader>jj', '<Cmd>AnyJumpVisual<CR>', desc = 'any-jump: jump' },
      { '<leader>jb', '<Cmd>AnyJumpBack<CR>', desc = 'any-jump: back' },
      { '<leader>jl', '<Cmd>AnyJumpLastResults<CR>', desc = 'any-jump: resume' },
    },
  },
  {
    'folke/trouble.nvim',
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>x', group = 'Trouble' })
      ar.add_to_select_menu('command_palette', {
        ['Trouble Diagnostics'] = 'TroubleToggle',
      })
    end,
    cond = ar.lsp.enable,
    cmd = { 'Trouble' },
    -- stylua: ignore
    keys = {
      { '<localleader>xd', '<Cmd>Trouble diagnostics toggle<CR>', desc = 'trouble: toggle diagnostics' },
      {
        '<localleader>xl',
        "<Cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = 'trouble: lsp references',
      },
      { '<localleader>xL', '<Cmd>Trouble loclist toggle<CR>', desc = 'trouble: toggle loclist' },
      { '<localleader>xq', '<Cmd>Trouble qflist toggle<CR>', desc  = 'trouble: toggle qflist' },
      { '<localleader>xt', '<Cmd>Trouble todo toggle<CR>', desc = 'trouble: toggle todo' },
      { '<localleader>xx', '<Cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'trouble: toggle buffer diagnostics' },
    },
    opts = {},
  },
  {
    'SmiteshP/nvim-navbuddy',
    cond = not minimal,
    keys = {
      {
        '<leader>nv',
        '<cmd>Navbuddy<cr>',
        desc = 'navbuddy: toggle',
      },
    },
    dependencies = { 'SmiteshP/nvim-navic' },
    opts = { lsp = { auto_attach = true } },
  },
  {
    'artemave/workspace-diagnostics.nvim',
    cond = ar.lsp.enable and ar_config.lsp.workspace_diagnostics.enable,
    opts = {},
  },
  --------------------------------------------------------------------------------
  -- Inlay Hints
  {
    'chrisgrieser/nvim-lsp-endhints',
    cond = ar.lsp.enable,
    event = 'LspAttach',
    opts = {
      icons = { type = '󰜁 ', parameter = '󰏪 ' },
      label = { padding = 1, marginLeft = 0 },
      autoEnableHints = ar_config.lsp.inlay_hint.enable,
    },
  },
  {
    'Davidyz/inlayhint-filler.nvim',
    -- NOTE: Doesn't work when nvim-lsp-endhints is enabled
    cond = ar.lsp.enable and false,
    keys = {
      {
        '<leader>lH',
        function() require('inlayhint-filler').fill() end,
        desc = 'insert inlay-hint under cursor intobuffer.',
      },
    },
  },
  --------------------------------------------------------------------------------
  -- Utils
  {
    'mhanberg/output-panel.nvim',
    init = function()
      ar.add_to_select_menu('lsp', { ['Output Panel'] = 'OutputPanel' })
    end,
    event = 'LspAttach',
    cond = not minimal and ar.lsp.enable,
    cmd = { 'OutputPanel' },
    opts = {},
    config = function(_, opts) require('output_panel').setup(opts) end,
  },
  {
    'bassamsdata/namu.nvim',
    cond = not minimal and ar.lsp.enable,
    keys = {
      {
        '<leader>ls',
        function() require('namu.namu_symbols').show() end,
        mode = { 'n', 'x', 'o' },
        desc = 'namu: show',
      },
    },
    opts = {
      namu_symbols = {
        enable = true,
        options = {}, -- here you can configure namu
      },
      ui_select = { enable = false }, -- vim.ui.select() wrapper
    },
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Disabled {{{1
  ------------------------------------------------------------------------------
  {
    'glepnir/lspsaga.nvim',
    enabled = false,
    cond = ar.lsp.enable and false,
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
        '<cmd>Lspsaga finder<cr>',
        desc = 'lspsaga: finder',
      },
      {
        'gD',
        function()
          local popup_id = detour.Detour()
          if popup_id then
            require('lspsaga.definition'):init(1, 2, {})
            features.ShowPathInTitle(popup_id)
          end
        end,
        desc = 'Goto Definition <gd>',
      },
      {
        'gR',
        function()
          local popup_id = detour.Detour()
          if popup_id then
            require('lspsaga.finder'):new({ 'ref', '++float' })
            features.ShowPathInTitle(popup_id)
          end
        end,
        desc = 'Goto References <gr>',
      },
      {
        'gI',
        function()
          local popup_id = detour.Detour()
          if popup_id then
            require('lspsaga.finder'):new({ 'imp', '++float' })
            features.ShowPathInTitle(popup_id)
          end
        end,
        desc = 'Goto Implementation <gI>',
      },
      {
        'gY',
        function()
          local popup_id = detour.Detour()
          if popup_id then
            require('lspsaga.definition'):init(2, 2, {})
            features.ShowPathInTitle(popup_id)
          end
        end,
        desc = 'Goto Type Definition <gy>',
      },
      {
        '<localleader>lci',
        function()
          local popup_id = detour.Detour()
          if popup_id then
            vim.bo.bufhidden = 'delete'
            require('lspsaga.callhierarchy'):send_method(2, { '++float' })
            features.ShowPathInTitle(popup_id)
          end
        end,
        desc = 'Incoming Calls [ci]',
      },
      {
        '<localleader>lco',
        function()
          local popup_id = detour.Detour()
          if popup_id then
            vim.bo.bufhidden = 'delete'
            require('lspsaga.callhierarchy'):send_method(3, { '++float' })
            features.ShowPathInTitle(popup_id)
          end
        end,
        desc = 'Outgoing Calls [co]',
      },
      {
        '<localleader>lp',
        '<cmd>Lspsaga peek_type_definition<cr>',
        desc = 'lspsaga: type definition',
      },
    },
  },
  {
    'kosayoda/nvim-lightbulb',
    enabled = false,
    cond = ar.lsp.enable and false,
    event = 'LspAttach',
    opts = {
      autocmd = { enabled = true },
      sign = { enabled = false },
      virtual_text = {
        enabled = true,
        text = icons.misc.lightbulb,
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
    'RaafatTurki/corn.nvim',
    enabled = false,
    cond = ar.lsp.enable and ar.plugins.niceties and false,
    event = 'LspAttach',
    cmd = { 'Corn' },
    opts = {
      icons = {
        error = lsp_icons.error,
        warn = lsp_icons.warn,
        hint = lsp_icons.hint,
        info = lsp_icons.info,
      },
    },
  },
  {
    'doums/dmap.nvim',
    enabled = false,
    cond = ar.lsp.enable and ar.plugins.niceties and false,
    event = 'LspAttach',
    opts = { win_h_offset = 5 },
  },
  {
    'ivanjermakov/troublesum.nvim',
    enabled = false,
    cond = ar.lsp.enable and ar.plugins.niceties and false,
    event = 'LspAttach',
    opts = {
      severity_format = {
        lsp_icons.error,
        lsp_icons.warn,
        lsp_icons.info,
        lsp_icons.hint,
      },
    },
  },
  {
    'roobert/action-hints.nvim',
    enabled = false,
    cond = ar.lsp.enable and false,
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
    enabled = false,
    cond = ar.lsp.enable and ar.plugins.niceties,
    -- stylua: ignore
    keys = {
      { '<leader>lA', function() require('actions-preview').code_actions() end, desc = 'code action preview' },
    },
    init = function()
      ar.add_to_select_menu('lsp', {
        ['Preview Code Actions'] = 'lua require("actions-preview").code_actions()',
      })
    end,
    config = function()
      require('actions-preview').setup({
        telescope = ar.telescope.vertical(),
      })
    end,
  },
  {
    'Wansmer/symbol-usage.nvim',
    enabled = false,
    cond = ar.lsp.enable and false,
    event = 'LspAttach',
    config = function()
      highlight.plugin('symbol-usage', {
        theme = {
          -- stylua: ignore
          ['onedark'] = {
            { SymbolUsageRounding = { italic = true, fg = { from = 'CursorLine', attr = 'bg' }, }, },
            { SymbolUsageContent = { italic = true, bg = { from = 'CursorLine' }, fg = { from = 'Comment' }, }, },
            { SymbolUsageRef = { italic = true, bg = { from = 'CursorLine' }, fg = { from = 'Function' }, }, },
            { SymbolUsageDef = { italic = true, bg = { from = 'CursorLine' }, fg = { from = 'Type' }, }, },
            { SymbolUsageImpl = { italic = true, bg = { from = 'CursorLine' }, fg = { from = '@keyword' }, }, },
            { SymbolUsageContent = { bold = false, italic = true, bg = { from = 'CursorLine' }, fg = { from = 'Comment' }, }, },
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
  {
    'luckasRanarison/clear-action.nvim',
    enabled = false,
    cond = ar.lsp.enable and ar.plugins.niceties,
    event = 'LspAttach',
    opts = {
      signs = {
        enable = true,
        combine = true,
        show_count = false,
        show_label = true,
        icons = {
          combined = icons.misc.lightbulb,
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
}
