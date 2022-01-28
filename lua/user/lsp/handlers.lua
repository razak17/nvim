-- Set Default Prefix.
-- Note: You can set a prefix per lsp server in the lv-globals.lua file
local M = {}

function M.setup()
  local config = { -- your config
    virtual_text = rvim.lsp.diagnostics.virtual_text,
    signs = rvim.lsp.diagnostics.signs,
    underline = rvim.lsp.diagnostics.underline,
    update_in_insert = rvim.lsp.diagnostics.update_in_insert,
    severity_sort = rvim.lsp.diagnostics.severity_sort,
    float = rvim.lsp.diagnostics.float,
  }
  vim.diagnostic.config(config)
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, rvim.lsp.float)
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    rvim.lsp.float
  )
end

function M.show_line_diagnostics()
  local config = rvim.lsp.diagnostics.float
  config.scope = "line"
  return vim.diagnostic.open_float(0, config)
end

return M
