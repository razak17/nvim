local api = vim.api

local M = {}

--- Convert arrow function to regular function
function M.arrow_to_function()
  local node = vim.treesitter.get_node()

  -- Find arrow_function node
  while node and node:type() ~= 'arrow_function' do
    node = node:parent()
  end
  if not node then
    return vim.notify('No arrow function found', vim.log.levels.WARN)
  end

  local parent = node:parent()
  if not parent then return end

  -- Get function name from variable_declarator or property assignment
  local name
  if parent:type() == 'variable_declarator' then
    local name_node = parent:field('name')[1]
    if name_node then name = vim.treesitter.get_node_text(name_node, 0) end
  end

  -- Get async prefix
  local text = vim.treesitter.get_node_text(node, 0)
  local is_async = vim.startswith(text, 'async')

  -- Get parameters
  local params_node = node:field('parameters')[1]
  local params = params_node and vim.treesitter.get_node_text(params_node, 0)
    or '()'

  -- Get return type if present
  local return_type_node = node:field('return_type')[1]
  local return_type = return_type_node
      and vim.treesitter.get_node_text(return_type_node, 0)
    or ''

  -- Get body
  local body_node = node:field('body')[1]
  if not body_node then return end
  local body = vim.treesitter.get_node_text(body_node, 0)

  -- Wrap expression body in braces with return
  if body_node:type() ~= 'statement_block' then
    body = '{\n  return ' .. body .. '\n}'
  end

  -- Build function
  local func = (is_async and 'async ' or '') .. 'function'
  if name then func = func .. ' ' .. name end
  func = func .. params .. return_type .. ' ' .. body

  -- Replace: if named, replace entire declaration; otherwise just arrow
  local target = name and parent or node

  -- Handle export const ComponentName = () => pattern
  local grandparent = parent and parent:parent()
  local export_prefix = ''
  if grandparent and grandparent:type() == 'lexical_declaration' then
    local ggparent = grandparent:parent()
    if ggparent and ggparent:type() == 'export_statement' then
      target = ggparent
      export_prefix = 'export '
    end
  end

  local sr, sc, er, ec = target:range()
  api.nvim_buf_set_text(
    0,
    sr,
    sc,
    er,
    ec,
    vim.split(export_prefix .. func, '\n')
  )
end

return M
