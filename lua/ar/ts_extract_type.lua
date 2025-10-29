local M = {}

-- https://github.com/emmanueltouzery/nvim_config/blob/dd12dad78f7663d7851cd26adea93808acc18995/ftplugin/typescript.lua?plain=1#L1
function M.extract_type()
  local parser = vim.treesitter.get_parser(0, nil, { error = false })
  if parser == nil then return end
  parser:parse()
  local ts_node = parser:named_node_for_range({
    vim.fn.line('.') - 1,
    vim.fn.col('.') - 1,
    vim.fn.line('.') - 1,
    vim.fn.col('.') - 1,
  })
  local parent = ts_node
  while parent do
    local p = parent:parent()
    if
      p == nil
      or p:type() == 'program'
      or p:type() == 'lexical_declaration'
      or p:type() == 'statement_block'
      or p:type() == 'required_parameter'
    then
      goto done
    end
    parent = p
  end
  ::done::
  if parent then
    if parent:parent() and parent:parent():type() == 'required_parameter' then
      -- this is a function parameter

      -- find the parameter index
      local param = parent:parent()
      local param_index = 0
      while param do
        param = param:prev_named_sibling()
        if param then
          local param_name =
            vim.treesitter.get_node_text(param:named_child('pattern'), 0)
          if param_name ~= 'this' then
            -- don't count the special fake parameter type annotation 'this'
            -- https://www.typescriptlang.org/docs/handbook/2/classes.html#this-parameters
            param_index = param_index + 1
          end
        end
      end

      -- find the function start location
      local row_node = parent
      while row_node do
        local p = row_node:parent()
        if
          p == nil
          or p:type() == 'program'
          or p:type() == 'lexical_declaration'
        then
          goto done
        end
        row_node = p
      end
      ::done::

      local declaration = 'type T = Parameters<typeof '
        .. require('aerial').get_location()[1].name
        .. '>['
        .. param_index
        .. ']'

      -- is this by any chance an object pattern matching?
      -- function({field1, field2})
      if parent:type() == 'object_pattern' then
        declaration = declaration .. "['" .. vim.fn.expand('<cword>') .. "']"
      end

      local row = row_node:start()
      vim.api.nvim_buf_set_lines(0, row, row, false, { declaration .. ';' })
      vim.api.nvim_win_set_cursor(0, { row + 1, 5 }) -- 5="type >T<"
    else
      -- normal variable
      local row = parent:start()
      vim.api.nvim_buf_set_lines(
        0,
        row,
        row,
        false,
        { 'type T = typeof ' .. vim.fn.expand('<cword>') .. ';' }
      )
      vim.api.nvim_win_set_cursor(0, { row + 1, 5 }) -- 5="type >T<"
    end
  end
end

return M
