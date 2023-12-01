local fn = vim.fn
local fmt = string.format
local ui, highlight = rvim.ui, rvim.highlight
local falsy, find_string = rvim.falsy, rvim.find_string
local border = ui.current.border

return {
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
            if not falsy(rvim.lsp.override) then
              if not find_string(rvim.lsp.override, name) then return end
            else
              local directory_disabled =
                ---@diagnostic disable-next-line: param-type-mismatch
                rvim.dirs_match(rvim.lsp.disabled.directories, cwd)
              local server_disabled =
                find_string(rvim.lsp.disabled.servers, name)
              if directory_disabled or server_disabled then return end
            end
            local config = require('rm.servers').get(name)
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
    -- stylua: ignore
    keys = {
      { '<leader>lo', '<cmd>Lspsaga outline<CR>', 'lspsaga: outline' },
      { '<localleader>lf', '<cmd>Lspsaga lsp_finder<cr>', desc = 'lspsaga: finder', },
      { '<localleader>la', '<cmd>Lspsaga code_action<cr>', desc = 'lspsaga: code action', },
      { '<M-p>', '<cmd>Lspsaga peek_type_definition<cr>', desc = 'lspsaga: type definition', },
      { '<M-i>', '<cmd>Lspsaga incoming_calls<cr>', desc = 'lspsaga: incoming calls', },
      { '<M-o>', '<cmd>Lspsaga outgoing_calls<cr>', desc = 'lspsaga: outgoing calls', },
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
    -- stylua: ignore
    keys = {
      { '<localleader>lri', function() require('rulebook').ignoreRule() end, desc = 'rulebook: ignore rule', },
      { '<localleader>lrl', function() require('rulebook').lookupRule() end, desc = 'rulebook: lookup rule', },
    },
  },
  {
    'luckasRanarison/clear-action.nvim',
    cond = rvim.lsp.enable,
    event = 'LspAttach',
    opts = {
      signs = {
        enable = true,
        combine = true,
        show_count = false,
        show_label = true,
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
    cond = rvim.lsp.enable and rvim.plugins.overrides.garbage_day.enable,
    event = 'LspAttach',
    opts = {
      grace_period = 60 * 15,
      notifications = true,
      excluded_languages = { 'java', 'markdown' },
    },
  },
  {
    'Wansmer/symbol-usage.nvim',
    cond = rvim.lsp.enable and false,
    event = 'LspAttach',
    config = function()
      highlight.plugin('symbol-usage', {
        -- stylua: ignore
        theme = {
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
    'stevanmilic/nvim-lspimport',
    cond = rvim.lsp.enable,
    ft = { 'python' },
    keys = {
      {
        '<localleader>la',
        function() require('lspimport').import() end,
        desc = 'lsp-import: import',
      },
    },
  },
  {
    'antosha417/nvim-lsp-file-operations',
    cond = rvim.lsp.enable,
    event = 'LspAttach',
    opts = {},
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-neo-tree/neo-tree.nvim' },
  },
  {
    'pechorin/any-jump.vim',
    cond = rvim.lsp.enable,
    cmd = { 'AnyJump', 'AnyJumpArg', 'AnyJumpLastResults' },
    -- stylua: ignore
    keys = {
      { '<leader>jj', '<Cmd>AnyJump<CR>', desc = 'any-jump: jump' },
      { '<leader>ja', '<Cmd>AnyJumpArg<CR>', desc = 'any-jump: arg' },
      { '<leader>jp', '<Cmd>AnyJumpLastResults<CR>', desc = 'any-jump: resume' },
    },
  },
  -- }}}
}
