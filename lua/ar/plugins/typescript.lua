local enabled = ar.lsp.enable

local filetypes = {
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.tsx',
}

local function typescript_tools_cond()
  if
    not ar.falsy(ar_config.lsp.override)
    and not ar.find_string(ar_config.lsp.override, 'typescript-tools')
  then
    return false
  end
  if ar.plugin_disabled('typescript-tools.nvim') or not ar.lsp.enable then
    return false
  end
  return ar_config.lsp.lang.typescript == 'typescript-tools'
end

return {
  'dmmulroy/ts-error-translator.nvim',
  {
    'yioneko/nvim-vtsls',
    cond = ar_config.lsp.lang.typescript == 'vtsls',
    ft = filetypes,
  },
  {

    'pmizio/typescript-tools.nvim',
    ft = filetypes,
    cond = typescript_tools_cond(),
    config = function(_, opts)
      local api = require('typescript-tools.api')
      opts.handlers = {
        ['textDocument/publishDiagnostics'] = api.filter_diagnostics({
          80001, -- Ignore this might be converted to a ES export
        }),
      }
      require('typescript-tools').setup(opts)
    end,
    opts = {
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
    'OlegGulevskyy/better-ts-errors.nvim',
    cond = enabled,
    event = 'LspAttach',
    ft = filetypes,
    opts = {
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
    init = function() ar.add_to_menu('lsp', { ['TSC'] = 'TSC' }) end,
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
