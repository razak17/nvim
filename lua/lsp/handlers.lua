-- Set Default Prefix.
-- Note: You can set a prefix per lsp server in the lv-globals.lua file
local M = {}

function M.setup()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = { spacing = 0, prefix = "" },
    signs = rvim.lsp.diagnostics.signs,
    underline = rvim.lsp.document_highlight,
  })

  vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, _, params, client_id, _)
    local config = { -- your config
      virtual_text = rvim.lsp.diagnostics.virtual_text,
      signs = rvim.lsp.diagnostics.signs,
      underline = rvim.lsp.diagnostics.underline,
      update_in_insert = rvim.lsp.diagnostics.update_in_insert,
      severity_sort = rvim.lsp.diagnostics.severity_sort,
    }
    local uri = params.uri
    local bufnr = vim.uri_to_bufnr(uri)

    if not bufnr then
      return
    end
    local diagnostics = params.diagnostics

    for i, v in ipairs(diagnostics) do
      local source = v.source
      if string.find(v.source, "/") then
        source = string.sub(v.source, string.find(v.source, "([%w-_]+)$"))
      end
      diagnostics[i].message = string.format("%s: %s", source, v.message)

      if vim.tbl_contains(vim.tbl_keys(v), "code") then
        diagnostics[i].message = diagnostics[i].message .. string.format(" [%s]", v.code)
      end
    end

    vim.lsp.diagnostic.save(diagnostics, bufnr, client_id)

    if not vim.api.nvim_buf_is_loaded(bufnr) then
      return
    end

    vim.lsp.diagnostic.display(diagnostics, bufnr, client_id, config)
  end

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = rvim.lsp.diagnostics.virtual_text,
    signs = rvim.lsp.diagnostics.signs.active,
    underline = rvim.lsp.document_highlight,
    update_in_insert = rvim.lsp.diagnostics.update_in_insert,
  })

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    show_header = false,
    border = rvim.lsp.popup_border,
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = rvim.lsp.popup_border }
  )
end

return M
