return {
  diagnostics = {
    signs = {
      active = true,
      values = {
        error = "",
        warn = "",
        info = "",
        hint = "",
      },
    },
    virtual_text = {
      -- severity = vim.diagnostic.severity.ERROR,
      source = "if_many",
      prefix = "",
      spacing = 2,
    },
    underline = true,
    border = "rounded",
    update_in_insert = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
      format = function(d)
        local t = vim.deepcopy(d)
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then
          t.message = string.format("%s [%s]", t.message, code):gsub("1. ", "")
        end
        return t.message
      end,
    },
  },
  document_highlight = true,
  code_lens_refresh = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
  },
  automatic_servers_installation = true,
  hover_diagnostics = false,
  null_ls = {
    setup = {
      debug = true,
      -- root_dir = require("lspconfig").util.root_pattern("Makefile", ".git", "node_modules"),
    },
    config = {},
  },
  formatting_ignore_list = { "tsserver", "html", "jsonls" },
  override = {
    "angularls",
    "ansiblels",
    "ccls",
    "csharp_ls",
    "cssmodules_ls",
    "denols",
    "ember",
    "emmet_ls",
    "eslint",
    "eslintls",
    "golangci_lint_ls",
    "grammarly",
    "graphql",
    "jedi_language_server",
    "ltex",
    "phpactor",
    "psalm",
    "pylsp",
    "quick_lint_js",
    "remark_ls",
    "rust_analyzer",
    "rome",
    "solang",
    "solidity_ls",
    "sorbet",
    "sourcekit",
    "spectral",
    "sqlls",
    "sqls",
    "stylelint_lsp",
    "tailwindcss",
    "tflint",
    "volar",
    "zk",
  },
}
