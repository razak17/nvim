local api = vim.api
local diagnostic = vim.diagnostic

local M = {}

local ts_servers = { 'tsgo', 'ts_ls', 'typescript-tools', 'vtsls', 'svelte' }

--- Get LSP diagnostics containing the cursor.
---@return lsp.Diagnostic[]
function M.get_diagnostic_at_cursor()
  local bufnr = api.nvim_get_current_buf()
  local cursor = api.nvim_win_get_cursor(0)
  local lnum, col = cursor[1] - 1, cursor[2]
  local cursor_pos = vim.pos(bufnr, lnum, col)
  local lsp_diagnostics = {}

  for _, diag in ipairs(diagnostic.get(bufnr, { lnum = lnum })) do
    local lsp_diagnostic = vim.tbl_get(diag, 'user_data', 'lsp')
    if lsp_diagnostic then
      local start = vim.pos(bufnr, diag.lnum, diag.col)
      local finish =
        vim.pos(bufnr, diag.end_lnum or diag.lnum, diag.end_col or diag.col)
      local contains_cursor = start == finish and cursor_pos == start
        or start <= cursor_pos and cursor_pos < finish
      if contains_cursor then table.insert(lsp_diagnostics, lsp_diagnostic) end
    end
  end

  return lsp_diagnostics
end

local function translate_ts_error(message, code)
  if not ar.has('ts-error-translator.nvim') then return message end
  local message_with_code = (
    code and ('TS' .. tostring(code) .. ': ' .. message) or message
  )
  local translator = require('ts-error-translator')
  local translated = translator.parse_errors(message_with_code)
  if translated and translated[1] and translated[1].improvedError then
    return translated[1].improvedError.body
  end
  return message
end

---@param diagnostics lsp.Diagnostic[]?
---@param is_ts_server boolean
local function process_diagnostics(diagnostics, is_ts_server)
  if ar.falsy(diagnostics) or not is_ts_server then return end

  for idx = #diagnostics, 1, -1 do
    if diagnostics ~= nil then
      local entry = diagnostics[idx]
      entry.message = translate_ts_error(entry.message, entry.code)
      if vim.tbl_contains(ar.lsp.disabled_codes.ts, entry.code) then
        table.remove(diagnostics, idx)
      end
    end
  end
end

---@param result lsp.PublishDiagnosticsParams|lsp.DocumentDiagnosticReport
---@param ctx lsp.HandlerContext
function M.on_publish_diagnostics(result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local is_ts_server = client ~= nil
    and vim.tbl_contains(ts_servers, client.name)

  process_diagnostics(result.diagnostics or result.items, is_ts_server)

  for _, related_result in pairs(result.relatedDocuments or {}) do
    if related_result.kind == 'full' then
      process_diagnostics(related_result.items, is_ts_server)
    end
  end
end

return M
