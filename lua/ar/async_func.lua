local api = vim.api

local M = {}

-- https://github.com/chrisgrieser/.config/blob/main/nvim/after/ftplugin/typescript.lua?plain=1#L36
function M.add()
  api.nvim_feedkeys('t', 'n', true) -- pass through the trigger char
  local col = api.nvim_win_get_cursor(0)[2]
  local text_before_cursor = api.nvim_get_current_line():sub(col - 3, col)
  if text_before_cursor ~= 'awai' then return end
  -----------------------------------------------------------------------------

  local func_node = vim.treesitter.get_node()
  local func_nodes = { 'arrow_function', 'function_declaration', 'function' }

  repeat -- loop trough ancestors till function node found
    func_node = func_node and func_node:parent()
    if not func_node then return end
  until vim.tbl_contains(func_nodes, func_node:type())

  local function_text = vim.treesitter.get_node_text(func_node, 0)
  if vim.startswith(function_text, 'async') then return end -- already async
  local start_row, start_col = func_node:start()
  -- stylua: ignore
  api.nvim_buf_set_text(0, start_row, start_col, start_row, start_col, { 'async ' })
end

return M
