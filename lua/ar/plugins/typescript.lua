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
    not ar.falsy(ar.lsp.override)
    and not ar.find_string(ar.lsp.override, 'typescript-tools')
  then
    return false
  end
  if ar.plugin_disabled('typescript-tools.nvim') or not ar.lsp.enable then
    return false
  end
  return ar.lsp.lang.typescript == 'typescript-tools'
end

return {
  'dmmulroy/ts-error-translator.nvim',
  {
    'yioneko/nvim-vtsls',
    cond = ar.lsp.lang.typescript == 'vtsls',
    ft = filetypes,
  },
  {

    'pmizio/typescript-tools.nvim',
    ft = filetypes,
    cond = typescript_tools_cond(),
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
