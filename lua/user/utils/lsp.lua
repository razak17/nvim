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
  vim.lsp.buf.document_highlight()
end

function rvim.lsp.tagfunc(pattern, flags)
  if flags ~= "c" then
    return vim.NIL
  end
  local params = vim.lsp.util.make_position_params()
  local client_id_to_results, err = vim.lsp.buf_request_sync(
    0,
    "textDocument/definition",
    params,
    500
  )
  assert(not err, vim.inspect(err))

  local results = {}
  for _, lsp_results in ipairs(client_id_to_results) do
    for _, location in ipairs(lsp_results.result or {}) do
      local start = location.range.start
      table.insert(results, {
        name = pattern,
        filename = vim.uri_to_fname(location.uri),
        cmd = string.format("call cursor(%d, %d)", start.line + 1, start.character + 1),
      })
    end
  end
  return results
end

function M.show_line_diagnostics()
  local config = rvim.lsp.diagnostics.float
  config.scope = "line"
  return vim.diagnostic.open_float(0, config)
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

function M.enable_lsp_document_highlight(client_id)
  rvim.augroup("LspCursorCommands", {
    {
      event = { "CursorHold" },
      buffer = 0,
      command = string.format(
        "lua require('user.utils.lsp').conditional_document_highlight(%d)",
        client_id
      ),
    },
    {
      event = { "CursorHoldI" },
      buffer = 0,
      command = "lua vim.lsp.buf.document_highlight()",
    },
    {
      event = { "CursorMoved" },
      buffer = 0,
      command = function()
        vim.lsp.buf.clear_references()
      end,
    },
  })
end

function M.disable_lsp_document_highlight()
  rvim.disable_augroup "lsp_document_highlight"
end

function M.enable_code_lens_refresh()
  rvim.augroup("LspCodeLensRefresh", {
    {
      event = { "InsertLeave" },
      buffer = 0,
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

function M.enable_lsp_hover_diagnostics()
  local get_cursor_pos = function()
    return { vim.fn.line ".", vim.fn.col "." }
  end

  rvim.augroup("HoverDiagnostics", {
    {
      event = { "CursorHold" },
      buffer = 0,
      command = (function()
        local cursorpos = get_cursor_pos()
        return function()
          local new_cursor = get_cursor_pos()
          if
            (new_cursor[1] ~= 1 and new_cursor[2] ~= 1)
            and (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2])
          then
            cursorpos = new_cursor
            vim.lsp.diagnostic.show_line_diagnostics { show_header = false, border = "single" }
          end
        end
      end)(),
    },
  })
end

return M
