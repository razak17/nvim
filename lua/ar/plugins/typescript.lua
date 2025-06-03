local enabled = ar.lsp.enable

-- stylua: ignore
local filetypes = {
  'javascript', 'javascriptreact', 'javascript.jsx',
  'typescript', 'typescriptreact', 'typescript.tsx',
}

local function cond(server, plugin)
  local override = ar_config.lsp.override
  if ar.plugin_disabled(plugin) or not ar.lsp.enable then return false end
  if not ar.falsy(override) then return ar.find_string(override, server) end
  return ar_config.lsp.lang.typescript == server
end

return {
  'dmmulroy/ts-error-translator.nvim',
  {
    'yioneko/nvim-vtsls',
    cond = function() return cond('vtsls', 'nvim-vtsls') end,
    ft = filetypes,
  },
  {
    'pmizio/typescript-tools.nvim',
    ft = filetypes,
    cond = function() return cond('typescript-tools', 'typescript-tools.nvim') end,
    opts = {
      handlers = {
        ['textDocument/publishDiagnostics'] = function(err, result, ctx)
          local lsp_diag = require('ar.lsp_diagnostics')
          local pub_diag = vim.lsp.diagnostic.on_publish_diagnostics
          lsp_diag.on_publish_diagnostics(err, result, ctx, pub_diag)
        end,
      },
      settings = {
        expose_as_code_action = 'all',
        complete_function_calls = false,
        jsx_close_tag = {
          enable = true,
          filetypes = { 'javascriptreact', 'typescriptreact' },
        },
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
    },
  },
  {
    'marilari88/twoslash-queries.nvim',
    cond = enabled,
    -- stylua: ignore
    keys = {
      { '<localleader>lI', '<Cmd>TwoslashQueriesInspect<CR>', desc = 'twoslash-queries: inspect', },
    },
    opts = { highlight = 'DiagnosticVirtualTextInfo' },
  },
  {
    'razak17/better-ts-errors.nvim',
    cond = enabled,
    event = 'LspAttach',
    ft = filetypes,
    keys = {
      {
        '<localleader>lo',
        function() require('better-ts-errors.diagnostics').show(true) end,
        desc = 'better-ts-errors: show error',
      },
    },
    opts = {
      default_mappings = false,
      enable_prettify = true,
      keymaps = {
        toggle = '<localleader>lo',
        go_to_definition = '<localleader>ld',
      },
    },
  },
  {
    'dmmulroy/tsc.nvim',
    cond = enabled,
    cmd = 'TSC',
    ft = filetypes,
    opts = {
      enable_progress_notifications = true,
      auto_open_qflist = true,
    },
    init = function() ar.add_to_select_menu('lsp', { ['TSC'] = 'TSC' }) end,
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

      ar.augroup('ReplaceQuickfixWithTrouble', {
        event = { 'BufWinEnter' },
        pattern = 'quickfix',
        command = replace_quickfix_with_trouble,
      })
    end,
  },
}
