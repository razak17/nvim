local M = {}

local function tsserver_on_attach(client, bufnr)
  client.resolved_capabilities.document_formatting = false

  local ts_utils = require "nvim-lsp-ts-utils"

  -- defaults
  ts_utils.setup {
    debug = false,
    disable_commands = false,
    enable_import_on_completion = false,
    import_all_timeout = 5000, -- ms

    -- eslint
    eslint_enable_code_actions = true,
    eslint_enable_disable_comments = true,
    -- eslint_bin = O.lang.tsserver.linter,
    eslint_config_fallback = nil,
    eslint_enable_diagnostics = true,

    -- formatting
    enable_formatting = true,
    formatter = "prettier",
    formatter_config_fallback = nil,

    -- parentheses completion
    complete_parens = false,
    signature_help_in_parens = false,

    -- update imports on file move
    update_imports_on_move = false,
    require_confirmation_on_move = false,
    watch_dir = nil,
  }

  -- required to fix code action ranges
  ts_utils.setup_client(client)
end

M.init = function()
  if core.check_lsp_client_active "tsserver" then
    return
  end
  require'lspconfig'.tsserver.setup {
    cmd = {core.lsp.binary.tsserver, "--stdio"},
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    capabilities = core.lsp.capabilities,
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      -- tsserver_on_attach(client, bufnr)
      core.lsp.on_attach(client, bufnr)
    end,
    settings = {documentFormatting = false},
    root_dir = require'lspconfig.util'.root_pattern('tsconfig.json', 'package.json', '.git',
      vim.fn.getcwd()),
  }
end

return M
