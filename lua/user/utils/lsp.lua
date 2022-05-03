local tbl = require "user.utils.table"

local M = {}

function M.is_client_active(name)
  local clients = vim.lsp.get_active_clients()
  return tbl.find_first(clients, function(client)
    return client.name == name
  end)
end

---Get all supported filetypes by nvim-lsp-installer
---@return table supported filestypes as a list of strings
function M.get_all_supported_filetypes()
  local status_ok, lsp_installer_filetypes = pcall(
    require,
    "nvim-lsp-installer._generated.filetype_map"
  )
  if not status_ok then
    return {}
  end
  return vim.tbl_keys(lsp_installer_filetypes or {})
end

function M.conditional_document_highlight(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).resolved_capabilities.document_highlight
  end)
  if not client_ok or not method_supported then
    return
  end
  pcall(vim.lsp.buf.document_highlight)
end

function M.show_line_diagnostics()
  local config = rvim.lsp.diagnostics.float
  config.scope = "line"
  return vim.diagnostic.open_float({ scope = "line" }, config)
end

---Get supported filetypes per server
---@param server_name string can be any server supported by nvim-lsp-installer
---@return table supported filestypes as a list of strings
function M.get_supported_filetypes(server_name)
  local status_ok, lsp_installer_servers = pcall(require, "nvim-lsp-installer.servers")
  if not status_ok then
    return {}
  end

  local server_available, requested_server = lsp_installer_servers.get_server(server_name)
  if not server_available then
    return {}
  end

  return requested_server:get_supported_filetypes()
end

function M.enable_lsp_document_highlight(client_id, bufnr)
  rvim.augroup("LspCursorCommands", {
    {
      event = { "CursorHold", "CursorHoldI" },
      buffer = bufnr,
      description = "LSP: Document Highlight",
      command = string.format(
        "lua require('user.utils.lsp').conditional_document_highlight(%d)",
        client_id
      ),
    },
    {
      event = { "CursorMoved" },
      description = "LSP: Document Highlight (Clear)",
      buffer = bufnr,
      command = function()
        vim.lsp.buf.clear_references()
      end,
    },
  })
end

function M.disable_lsp_document_highlight()
  rvim.disable_augroup "lsp_document_highlight"
end

--- Add lsp autocommands
---@param bufnr number
function M.enable_code_lens_refresh(bufnr)
  rvim.augroup("LspCodeLensRefresh", {
    {
      event = { "InsertLeave" },
      buffer = bufnr,
      command = "lua vim.lsp.codelens.refresh()",
    },
    {
      event = { "InsertLeave" },
      buffer = 0,
      command = "lua vim.lsp.codelens.display()",
    },
  })
end

function M.disable_code_lens_refresh()
  rvim.disable_augroup "lsp_code_lens_refresh"
end

function M.enable_lsp_hover_diagnostics(bufnr)
  rvim.augroup("HoverDiagnostics", {
    {
      event = { "CursorHold" },
      buffer = bufnr,
      command = function()
        vim.diagnostic.open_float({ scope = "line" }, { focus = false })
      end,
    },
  })
end

---filter passed to vim.lsp.buf.format
---gives higher priority to null-ls
---@param clients table clients attached to a buffer
---@return table chosen clients
function M.format_filter(clients)
  return vim.tbl_filter(function(client)
    local status_ok, formatting_supported = pcall(function()
      return client.supports_method "textDocument/formatting"
    end)
    -- give higher prio to null-ls
    if status_ok and formatting_supported and client.name == "null-ls" then
      return "null-ls"
    else
      return status_ok and formatting_supported and client.name
    end
  end, clients)
end

---Provide vim.lsp.buf.format for nvim <0.8
---@param opts table
function M.format(opts)
  opts = opts or { filter = M.format_filter }

  if vim.lsp.buf.format then
    vim.lsp.buf.format(opts)
  end

  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.buf_get_clients(bufnr)

  if opts.filter then
    clients = opts.filter(clients)
  elseif opts.id then
    clients = vim.tbl_filter(function(client)
      return client.id == opts.id
    end, clients)
  elseif opts.name then
    clients = vim.tbl_filter(function(client)
      return client.name == opts.name
    end, clients)
  end

  clients = vim.tbl_filter(function(client)
    return client.supports_method "textDocument/formatting"
  end, clients)

  if #clients == 0 then
    vim.notify "[LSP] Format request failed, no matching language servers."
  end

  local timeout_ms = opts.timeout_ms or 1000
  for _, client in pairs(clients) do
    local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
    local result, err = client.request_sync("textDocument/formatting", params, timeout_ms, bufnr)
    if result and result.result then
      vim.lsp.util.apply_text_edits(result.result, bufnr, client.offset_encoding)
    elseif err then
      vim.notify(string.format("[LSP][%s] %s", client.name, err), vim.log.levels.WARN)
    end
  end
end

return M
