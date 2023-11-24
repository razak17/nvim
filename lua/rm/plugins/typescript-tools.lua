return {
  'pmizio/typescript-tools.nvim',
  -- event = { 'BufReadPre', 'BufNewFile' },
  ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  cond = rvim.lsp.enable
    and not rvim.find_string(rvim.plugins.disabled, 'typescript-tools.nvim'),
  dependencies = {
    'nvim-lua/plenary.nvim',
    'neovim/nvim-lspconfig',
    'davidosomething/format-ts-errors.nvim',
    {
      'razak17/twoslash-queries.nvim',
        -- stylua: ignore
        keys = {
          { '<localleader>li', '<Cmd>TwoslashQueriesInspect<CR>', desc = 'twoslash-queries: inspect', },
        },
      opts = {},
      config = function(_, opts)
        rvim.highlight.plugin('twoslash-queries', {
          theme = {
            ['onedark'] = {
              { TypeVirtualText = { link = 'DiagnosticVirtualTextInfo' } },
            },
          },
        })
        require('twoslash-queries').setup(opts)
      end,
    },
  },
  opts = {
    on_attach = function(client, bufnr)
      require('twoslash-queries').attach(client, bufnr)
    end,
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
}
