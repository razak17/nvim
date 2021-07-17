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

M.setup = function(capabilities)
  require'lspconfig'.tsserver.setup {
    capabilities = capabilities,
    -- on_attach = tsserver_on_attach,
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      tsserver_on_attach(client, bufnr)
      core.lsp.on_attach(client, bufnr)
    end,

    settings = {documentFormatting = false},
    root_dir = require'lspconfig.util'.root_pattern('tsconfig.json', 'package.json', '.git',
      vim.fn.getcwd()),
  }
end

local ts_lint = function(capabilities)
  local eslint = {
    lintCommand = "eslint" .. "-f visualstudio --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m"},
    lintSource = "eslint",
    lintIgnoreExitCode = true,
    formatCommand = "eslint" .. " --fix-to-stdout --stdin  --stdin-filename=${INPUT}",
    formatStdin = true,
  }
  require'lspconfig'.efm.setup {
    capabilities = capabilities,
    on_attach = core.lsp.on_attach,
    init_options = {documentFormatting = true, codeAction = false},
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascriptreact.jsx",
      "typescript",
      "typescriptreact",
      "typescriptreact.tsx",
    },
    settings = {
      rootMarkers = {"package.json", "tsconfig.json", ".gitignore", ".git/"},
      languages = {
        javascript = {eslint},
        javascriptreact = {eslint},
        ["javascriptreact.jsx"] = {eslint},
        typescript = {eslint},
        typescriptreact = {eslint},
        ["typescriptreact.tsx"] = {eslint},
      },
    },
  }
end

M.lint = function(capabilities)
  if core.executable("efm-langserver") then
    ts_lint(capabilities)
  end
end

return M
