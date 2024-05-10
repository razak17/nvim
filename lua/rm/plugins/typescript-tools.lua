local enabled = rvim.lsp.enable
  and not rvim.plugin_disabled('typescript-tools.nvim')
  and rvim.lsp.typescript_tools.enable

return {
  {

    'pmizio/typescript-tools.nvim',
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    cond = enabled,
    -- stylua: ignore
    keys = {
      { '<localleader>li', '<Cmd>TSToolsAddMissingImports<CR>', desc = 'add missing imports' },
      { '<localleader>lx', '<Cmd>TSToolsRemoveUnusedImports<CR>', desc = 'remove unused missing imports' },
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
        ['textDocument/publishDiagnostics'] = function(
          err,
          result,
          ctx,
          config
        )
          if result.diagnostics == nil then return end

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
        ft = { 'typescript', 'typescriptreact' },
        opts = {
          enable_progress_notifications = true,
          auto_open_qflist = true,
        },
        config = function(_, opts)
          require('tsc').setup(opts)

          -- Replace the quickfix window with Trouble when viewing TSC results
          local function replace_quickfix_with_trouble()
            local qflist = vim.fn.getqflist({ title = 0, items = 0 })

            if qflist.title ~= 'TSC' then return end

            local ok, trouble = pcall(require, 'trouble')

            if ok then
              -- close trouble if there are no more items in the quickfix list
              if next(qflist.items) == nil then
                vim.defer_fn(trouble.close, 0)
                return
              end

              vim.defer_fn(function()
                vim.cmd('cclose')
                trouble.open('quickfix')
              end, 0)
            end
          end

          rvim.augroup('ReplaceQuickfixWithTrouble', {
            event = { 'BufWinEnter' },
            pattern = 'quickfix',
            command = replace_quickfix_with_trouble,
          })
        end,
      },
    },
  },
}
