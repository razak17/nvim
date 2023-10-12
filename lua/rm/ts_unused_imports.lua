if not rvim or not rvim.plugins.enable then return end

local M = {}

-- alternative options:
-- * using tsserver LSP support (but wants to remove the react import,
--   want to reorganize imports except from TS 4.9+, is a little slow).
-- * using eslint autofix (but must still call in a loop, and i didn't
--   realize until late that this was an option)
local strings = require('plenary.strings')

local function add_comma_node(node)
  local comma_node = node:next_sibling()
  if comma_node ~= nil and comma_node:type() == ',' then
    return node, comma_node
  end
  comma_node = node:prev_sibling()
  if comma_node:type() == ',' then return comma_node, node end
  print('ERROR EXPECTED COMMA NODE, GOT ' .. comma_node:type())
  return nil, nil
end

local function can_wipe_till_start_of_line(node)
  local start_row, _, _, _ = node:range()
  local can_wipe = false
  local prev_sibling = node:prev_sibling()
  if prev_sibling ~= nil then
    local _, _, prev_item_end_row, _ = prev_sibling:range()
    can_wipe = prev_item_end_row < start_row
  end
  return can_wipe
end

local function can_wipe_eol(node)
  local _, _, end_row, _ = node:range()
  local can_wipe = false
  local next_sibling = node:next_sibling()
  if next_sibling ~= nil then
    local next_item_start_row, _, _, _ = next_sibling:range()
    can_wipe = next_item_start_row > end_row
  end
  return can_wipe
end

local function delete_lines(lstart, lend)
  vim.api.nvim_buf_set_lines(0, lstart, lend + 1, false, {})
end

local function delete_range(start_row, start_col, end_row, end_col)
  local start_line =
    vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
  local end_line = vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1]
  local new_start = strings.strcharpart(start_line, 0, start_col)
  local new_end = strings.strcharpart(end_line, end_col)
  local new_lines_arr
  if start_row == end_row then
    new_lines_arr = { new_start .. new_end }
  else
    new_lines_arr = { new_start, new_end }
  end
  vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, new_lines_arr)
end

local function delete_node(node)
  local row_start, _, row_end, _ = node:range()
  if can_wipe_till_start_of_line(node) and can_wipe_eol(node) then
    delete_lines(row_start, row_end)
  else
    delete_range(node:range())
  end
end

local function delete_successive_nodes(node1, node2)
  local row_start1, _, _, _ = node1:range()
  if can_wipe_till_start_of_line(node1) and can_wipe_eol(node2) then
    local _, _, row_end2, _ = node2:range()
    delete_lines(row_start1, row_end2)
  else
    local n1sl, n1sc, n1el, n1ec = node1:range()
    delete_range(node2:range())
    delete_range(n1sl, n1sc, n1el, n1ec)
  end
end

local function typescript_remove_unused_import(diag)
  if diag.code == '@typescript-eslint/no-unused-vars' then
    local parser = require('nvim-treesitter.parsers').get_parser(0)
    parser:parse()
    local ts_node =
      parser:named_node_for_range({ diag.lnum, diag.col, diag.lnum, diag.col })
    local parent1 = ts_node:parent()
    local parent2 = parent1 and parent1:parent()
    local parent3 = parent2 and parent2:parent()
    local parent4 = parent3 and parent3:parent()

    if
      parent1
      and parent2
      and parent1:type() == 'import_clause'
      and parent2:type() == 'import_statement'
    then
      local import_count_at_toplevel = parent1:named_child_count()
      if import_count_at_toplevel == 1 then
        delete_node(parent2)
      else
        local node1, node2 = add_comma_node(ts_node)
        delete_successive_nodes(node1, node2)
      end
    elseif
      parent1
      and parent2
      and parent3
      and parent4
      and parent1:type() == 'import_specifier'
      and parent2:type() == 'named_imports'
      and parent3:type() == 'import_clause'
      and parent4:type() == 'import_statement'
    then
      local import_count_in_my_braces = parent2:named_child_count()
      local import_count_at_toplevel = parent3:named_child_count()
      if import_count_in_my_braces == 1 and import_count_at_toplevel == 1 then
        delete_node(parent4)
      elseif import_count_in_my_braces == 1 then
        local node1, node2 = add_comma_node(parent2)
        delete_successive_nodes(node1, node2)
      else
        local node1, node2 = add_comma_node(parent1)
        delete_successive_nodes(node1, node2)
      end
    end
  end
end

function M.remove_unused_imports()
  local filetypes = { 'typescript', 'typescriptreact' }
  if vim.tbl_contains(filetypes, vim.bo.filetype) then
    local sorted_diags = vim.diagnostic.get(0)
    table.sort(
      sorted_diags,
      function(a, b)
        return a.lnum > b.lnum or (a.lnum == b.lnum and a.col > b.col)
      end
    )
    print(
      'DEBUGPRINT[1]: ts_unused_imports.lua:136: sorted_diags='
        .. vim.inspect(sorted_diags)
    )
    for _, diag in ipairs(sorted_diags) do
      typescript_remove_unused_import(diag)
    end
  else
    print('Not supported for this file type!')
  end
end

return M
