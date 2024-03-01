return {
  {

    'pmizio/typescript-tools.nvim',
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    cond = rvim.lsp.enable
      and not rvim.find_string(rvim.plugins.disabled, 'typescript-tools.nvim'),
    -- stylua: ignore
    keys = {
      { '<localleader>li', '<Cmd>TSToolsAddMissingImports<CR>', desc = 'add missing imports' },
      { '<localleader>lx', '<Cmd>TSToolsRemoveUnusedImports<CR>', desc = 'remove unused missing imports' },
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
        ['textDocument/publishDiagnostics'] = function(
          err,
          result,
          ctx,
          config
        )
          if result.diagnostics == nil then return end

          -- ignore some tsserver diagnostics
          local idx = 1
          local translate = require('ts-error-translator').translate

          while idx <= #result.diagnostics do
            local entry = result.diagnostics[idx]

            if translate then
              local translatedMessage = translate({
                code = entry.code,
                message = entry.message,
              })
              entry.message = translatedMessage.message
            end

            -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
            if entry.code == 80001 then
              -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
              table.remove(result.diagnostics, idx)
            else
              idx = idx + 1
            end
          end

          vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
        end,
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
      'dmmulroy/ts-error-translator.nvim',
      {
        'OlegGulevskyy/better-ts-errors.nvim',
        opts = {
          keymaps = {
            toggle = '<localleader>lo',
            go_to_definition = '<localleader>ld',
          },
        },
        dependencies = { 'MunifTanjim/nui.nvim' },
      },
      {
        'razak17/twoslash-queries.nvim',
        -- stylua: ignore
        keys = {
          { '<localleader>lI', '<Cmd>TwoslashQueriesInspect<CR>', desc = 'twoslash-queries: inspect', },
        },
        opts = {},
        config = function(_, opts)
          require('twoslash-queries').setup(opts)

          rvim.highlight.plugin('twoslash-queries', {
            theme = {
              ['onedark'] = {
                { TypeVirtualText = { link = 'DiagnosticVirtualTextInfo' } },
              },
            },
          })
        end,
      },
      {
        'dmmulroy/tsc.nvim',
        cond = rvim.lsp.enable,
        cmd = 'TSC',
        opts = {},
        ft = { 'typescript', 'typescriptreact' },
      },
    },
  },
}
