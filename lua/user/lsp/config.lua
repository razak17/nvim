local border = rvim.style.border.current

rvim.lsp = {
  templates_dir = join_paths(rvim.get_config_dir(), "after", "ftplugin"),
  diagnostics = {
    signs = { active = true },
    virtual_text_spacing = 2,
    underline = true,
    border = border,
    update_in_insert = false,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = border,
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
    border = border,
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
  no_format_on_save_ft = {"zsh"},
  formatting_ignore_list = { "sumneko_lua", "tsserver", "html", "jsonls", "gopls" },
  emmet_ft = {
    "html",
    "css",
    "javascriptreact",
    "javascript.jsx",
    "typescriptreact",
    "typescript.tsx",
  },
  override_servers = {
    rust_analyzer = "rust_analyzer",
    golangci_lint_ls = "golangci_lint_ls",
    sqlls = "sqlls",
  },
  override_ft = {
    "go",
    "rust",
    "mysql",
    "sql",
  },
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
    "gopls",
    "grammarly",
    "graphql",
    "jedi_language_server",
    "ltex",
    "phpactor",
    "psalm",
    "pylsp",
    "remark_ls",
    "rome",
    "solang",
    "solidity_ls",
    "sorbet",
    "sourcekit",
    "spectral",
    "sqls",
    "stylelint_lsp",
    "tailwindcss",
    "tflint",
    "volar",
    "zk",
  },
  kind_highlights = {
    Text = "String",
    Method = "Method",
    Function = "Function",
    Constructor = "TSConstructor",
    Field = "Field",
    Variable = "Variable",
    Class = "Class",
    Interface = "Constant",
    Module = "Include",
    Property = "Property",
    Unit = "Constant",
    Value = "Variable",
    Enum = "Type",
    Keyword = "Keyword",
    File = "Directory",
    Reference = "PreProc",
    Constant = "Constant",
    Struct = "Type",
    Event = "Variable",
    Operator = "Operator",
    TypeParameter = "Type",
  },
}
