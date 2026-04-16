local lsp, api = vim.lsp, vim.api
local L = vim.log.levels

local M = {}

-- possible values for the style: "background", "foreground", "virtual", or any string character
-- DOCUMENT_COLOR_STYLE in all caps to save the variable between sessions
local styles = { 'background', 'foreground', 'virtual' }

---@param bufnr? number
local function apply_color(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  vim.g.DOCUMENT_COLOR_STYLE = ((vim.g.DOCUMENT_COLOR_STYLE or 1) % #styles) + 1
  lsp.document_color.enable(false)
  lsp.document_color.enable(
    true,
    { bufnr = bufnr },
    { style = styles[vim.g.DOCUMENT_COLOR_STYLE] }
  )
end

function M.cycle_style()
  vim.g.DOCUMENT_COLOR_STYLE = (vim.g.DOCUMENT_COLOR_STYLE or 1) + 1
  apply_color()
  vim.notify(
    'Document color style: ' .. styles[vim.g.DOCUMENT_COLOR_STYLE],
    L.INFO,
    { title = 'LSP Document Color' }
  )
end

return M
