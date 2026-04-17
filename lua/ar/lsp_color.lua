local lsp, api = vim.lsp, vim.api

-- https://www.reddit.com/r/neovim/comments/1sho7j6/i_created_a_document_color_cycle_function_for_012/

local M = {}

-- possible values for the style: "background", "foreground", "virtual", or any string character
-- DOCUMENT_COLOR_STYLE in all caps to save the variable between sessions
local styles = { 'background', 'foreground', 'virtual' }
local styles_map = {
  background = 1,
  foreground = 2,
  virtual = 3,
}

---@param style? string
function M.set_style(style)
  style = style or vim.g.DOCUMENT_COLOR_STYLE or 'background'
  bufnr = bufnr or api.nvim_get_current_buf()
  vim.g.DOCUMENT_COLOR_STYLE = style
  lsp.document_color.enable(false)
  lsp.document_color.enable(true, nil, { style = style })
end

function M.cycle_style()
  local idx = ((styles_map[vim.g.DOCUMENT_COLOR_STYLE] or 1) % #styles)
  M.set_style(styles[(idx % #styles) + 1])
end

return M
