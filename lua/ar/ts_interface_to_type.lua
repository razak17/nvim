local api, fn = vim.api, vim.fn

local M = {}

-- Helper function to find the interface node
local function find_interface_node(node)
  if not node then return nil end

  if node:type() == 'interface_declaration' then return node end

  return find_interface_node(node:parent())
end

-- Helper function to convert interface body to type body
local function convert_interface_body(body_node)
  local body_text = vim.treesitter.get_node_text(body_node, 0)
  -- Remove leading '{' and trailing '}'
  body_text = body_text:sub(2, -2):gsub('^%s*(.-)%s*$', '%1')
  return body_text
end

-- Main function to convert interface to type
function M.interface_to_type()
  local buffer = fn.bufnr()
  local parser = vim.treesitter.get_parser(buffer, 'typescript')
  if not parser then return end
  local tree = parser:parse()[1]
  local root = tree:root()

  local cursor_pos = api.nvim_win_get_cursor(0)
  local row, col = cursor_pos[1] - 1, cursor_pos[2]

  local current_node = root:named_descendant_for_range(row, col, row, col)
  local interface_node = find_interface_node(current_node)

  if not interface_node then
    print('No interface found at cursor position')
    return
  end

  local interface_name =
    vim.treesitter.get_node_text(interface_node:child(1), buffer)
  local interface_body = interface_node:child(2)

  if not interface_body then
    print('Invalid interface structure')
    return
  end

  local type_body = convert_interface_body(interface_body)
  local type_declaration =
    string.format('type %s = {%s}', interface_name, type_body)

  local start_row, _, end_row, _ = interface_node:range()

  -- Split the type declaration into lines
  local lines = vim.split(type_declaration, '\n')

  -- Replace the interface with the new type declaration
  api.nvim_buf_set_lines(buffer, start_row, end_row + 1, false, lines)

  print('Converted interface to type: ' .. interface_name)
end

return M
