local minimal = ar.plugins.minimal
local enabled = not minimal and ar.lsp.enable

-- stylua: ignore
local filetypes = {
  'javascript', 'javascriptreact', 'javascript.jsx',
  'typescript', 'typescriptreact', 'typescript.tsx',
}

local function cond(server, plugin)
  local override = ar.config.lsp.override
  if not ar.lsp.enable then return false end
  if not ar.falsy(override) then return vim.tbl_contains(override, server) end
  return ar.get_plugin_cond(plugin, ar.config.lsp.lang.typescript[server])
end

ar.pack.add({
  {
    src = 'https://github.com/dmmulroy/ts-error-translator.nvim',
    cond = function() return ar.get_plugin_cond('ts-error-translator.nvim') end,
    setup = function()
      require('ts-error-translator').setup({ auto_attach = false })
    end,
  },
  {
    src = 'https://github.com/yioneko/nvim-vtsls',
    cond = function() return cond('vtsls', 'nvim-vtsls') end,
    ft = filetypes,
  },
  {
    src = 'https://github.com/pmizio/typescript-tools.nvim',
    ft = filetypes,
    cond = function() return cond('typescript-tools', 'typescript-tools.nvim') end,
    setup = function()
      require('typescript-tools').setup({
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
      })
    end,
  },
  {
    src = 'https://github.com/marilari88/twoslash-queries.nvim',
    cond = function()
      return ar.get_plugin_cond('twoslash-queries.nvim', enabled)
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>lI', '<Cmd>TwoslashQueriesInspect<CR>', desc = 'twoslash-queries: inspect', },
    },
    setup = function()
      require('twoslash-queries').setup({
        highlight = 'DiagnosticVirtualTextInfo',
      })
    end,
  },
  {
    src = 'https://github.com/razak17/better-ts-errors.nvim',
    cond = function()
      return ar.get_plugin_cond('better-ts-errors.nvim', enabled)
    end,
    ft = filetypes,
    keys = {
      {
        '<localleader>lo',
        function() require('better-ts-errors.diagnostics').show(true) end,
        desc = 'better-ts-errors: show error',
      },
    },
    setup = function()
      require('better-ts-errors').setup({
        default_mappings = false,
        enable_prettify = true,
        keymaps = {
          toggle = '<localleader>lo',
          go_to_definition = '<localleader>ld',
        },
      })
    end,
    dependencies = { { src = 'MunifTanjim/nui.nvim' } },
  },
  {
    src = 'https://github.com/dmmulroy/tsc.nvim',
    cond = function() return ar.get_plugin_cond('tsc.nvim', enabled) end,
    cmd = { 'TSC' },
    ft = filetypes,
    init = function() ar.add_to_select('lsp', { ['TSC'] = 'TSC' }) end,
    setup = function()
      require('tsc').setup({
        enable_progress_notifications = true,
        auto_open_qflist = true,
      })

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
  {
    src = 'https://github.com/nemanjamalesija/ts-expand-hover.nvim',
    cond = function()
      return ar.get_plugin_cond('ts-expand-hover.nvim', enabled)
    end,
    ft = { 'typescript', 'typescriptreact' },
    keys = {
      {
        '<leader>K',
        function() require('ts_expand_hover').hover() end,
        desc = 'ts-expand-hover: open',
      },
    },
    setup = function()
      require('ts_expand_hover').setup({
        keymaps = { hover = false },
        float = { border = ar.ui.current.border.default },
      })
    end,
  },
  {
    src = 'https://github.com/xeind/vallow.nvim',
    cond = function() return ar.get_plugin_cond('vallow.nvim', enabled) end,
    cmd = { 'Vallow', 'VallowRefresh', 'VallowSearch' },
    opts = {},
    setup = function() require('vallow').setup() end,
  },
})
