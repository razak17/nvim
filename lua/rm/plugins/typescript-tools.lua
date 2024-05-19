local enabled = rvim.lsp.enable
  and not rvim.plugin_disabled('typescript-tools.nvim')
  and rvim.lsp.typescript_tools.enable

return {
  'dmmulroy/ts-error-translator.nvim',
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
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
    },
  },
  {
    'razak17/twoslash-queries.nvim',
    -- stylua: ignore
    keys = {
      { '<localleader>lI', '<Cmd>TwoslashQueriesInspect<CR>', desc = 'twoslash-queries: inspect', },
    },
    opts = { highlight = 'DiagnosticVirtualTextInfo' },
  },
  {
    'OlegGulevskyy/better-ts-errors.nvim',
    event = 'LspAttach',
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    opts = {
      keymaps = {
        toggle = '<localleader>lo',
        go_to_definition = '<localleader>ld',
      },
    },
    dependencies = { 'MunifTanjim/nui.nvim' },
  },
  {
    'dmmulroy/tsc.nvim',
    cond = rvim.lsp.enable,
    cmd = 'TSC',
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
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
}
