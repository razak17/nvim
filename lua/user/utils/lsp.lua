local tbl = require("user.utils.table")

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

local function check_hi(client)
  local status_ok, highlight_supported = pcall(function()
    return client.server_capabilities.documentHighlightProvider
  end)
  return status_ok, highlight_supported
end

function M.setup_document_highlight(client, bufnr)
  local status_ok, highlight_supported = check_hi(client)
  if not status_ok or not highlight_supported then
    return
  end

  rvim.augroup("LspCursorCommands", {
    {
      event = { "CursorHold", "CursorHoldI" },
      buffer = bufnr,
      desc = "LSP: Document Highlight",
      command = vim.lsp.buf.document_highlight,
    },
    {
      event = { "CursorMoved" },
      desc = "LSP: Document Highlight (Clear)",
      buffer = bufnr,
      command = function()
        vim.lsp.buf.clear_references()
      end,
    },
  })
end

function M.illuminate_highlight(client)
  local status_ok, illuminate = rvim.safe_require("illuminate")
  if not status_ok then
    return
  end
  illuminate.on_attach(client)
end

function M.navic(client, bufnr)
  local ok, navic = pcall(require, "nvim-navic")
  if ok and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
end

--- Add lsp autocommands
---@param bufnr number
function M.setup_code_lens_refresh(client, bufnr)
  local status_ok, codelens_supported = pcall(function()
    return client.server_capabilities.codeLensProvider
  end)
  if not status_ok or not codelens_supported then
    return
  end

  rvim.augroup("LspCodeLensRefresh", {
    {
      event = { "BufEnter", "CursorHold", "InsertLeave" },
      buffer = bufnr,
      command = "lua vim.lsp.codelens.refresh()",
    },
  })
end

-- Show the popup diagnostics window, but only once for the current cursor location
-- by checking whether the word under the cursor has changed.
local function diagnostic_popup()
  local cword = vim.fn.expand("<cword>")
  if cword ~= vim.w.lsp_diagnostics_cword then
    vim.w.lsp_diagnostics_cword = cword
    vim.diagnostic.open_float(0, { scope = "cursor", focus = false })
  end
end

function M.setup_hover_diagnostics(client, bufnr)
  local status_ok, highlight_supported = check_hi(client)
  if not status_ok or not highlight_supported then
    return
  end

  rvim.augroup("HoverDiagnostics", {
    {
      event = { "CursorHold" },
      buffer = bufnr,
      command = function()
        diagnostic_popup()
      end,
    },
  })
end

function M.setup_setup_tagfunc(client, bufnr)
  local status_ok, highlight_supported = pcall(function()
    return client.server_capabilities.documentFormattingProvider
  end)
  if not status_ok or not highlight_supported then
    return
  end

  vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
end

function M.setup_format_expr(client, bufnr)
  local status_ok, highlight_supported = pcall(function()
    return client.server_capabilities.definitionProvider
  end)
  if not status_ok or not highlight_supported then
    return
  end

  vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
end

---filter passed to vim.lsp.buf.format
---gives higher priority to null-ls
---@param clients table clients attached to a buffer
---@return table chosen clients
function M.format_filter(clients)
  return vim.tbl_filter(function(client)
    local status_ok, formatting_supported = pcall(function()
      return client.server_capabilities.documentFormattingProvider
    end)

    if vim.tbl_contains(rvim.lsp.format_exclusions, clients.name) then
      clients.server_capabilities.documentFormattingProvider = false
    end

    -- give higher priority to null-ls
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
    return client.supports_method("textDocument/formatting")
  end, clients)

  if #clients == 0 then
    vim.notify("[LSP] Format request failed, no matching language servers.")
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
