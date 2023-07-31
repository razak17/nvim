if not rvim then return end

local file
local extensions = { 'js', 'ts', 'cjs', 'mjs' }
for _, ext in ipairs(extensions) do
  file = io.open(vim.fn.expand('%:p:h') .. '/tailwind.config.' .. ext, 'r')
  if file then break end
end
local disabled = not file or rvim.minimal or not rvim.plugins.enable or rvim.plugins.minimal

if disabled then return end

-- ref: https://github.com/MaximilianLloyd/Dotfiles/blob/master/nvim/.config/nvim/lua/maximilianlloyd/init.lua

----------------------------------------------------------------------------------------------------
-- Tailwind utility to get all applied CSS values on an element
----------------------------------------------------------------------------------------------------
if pcall(require, 'plenary') then
  RELOAD = require('plenary.reload').reload_module

  R = function(name)
    print('Reloading: ' .. name)
    RELOAD(name)
    return require(name)
  end
end

local function count_leading_whitespace(line)
  local leadingWhitespace = string.match(line, '^[ \t]*')
  return leadingWhitespace and #leadingWhitespace or 0
end

local function mysplit(inputstr, sep, init_col, init_row)
  if sep == nil then sep = '%s' end
  local t = {}
  -- If there are mulitple new lines
  local row_offset = init_row

  for row in string.gmatch(inputstr, '([^\n]+)') do
    local offset = 0
    local whitespace = count_leading_whitespace(row)
    local base_col = init_col

    if whitespace ~= 0 then
      print('Whitespace found')
      base_col = whitespace
    end

    for str in string.gmatch(row, '([^' .. sep .. ']+)') do
      local start_pos, end_pos = row:find(str, offset + 1, true)
      local new_col = base_col + start_pos - 1

      table.insert(t, {
        str = str,
        col = new_col,
        row = row_offset,
      })
      offset = offset + #str + 1
    end

    -- Increment for each new line
    row_offset = row_offset + 1
  end
  return t
end

local function tailwind_classes(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local cursor = vim.treesitter.get_node({
    bufnr = bufnr,
  })

  if cursor == nil then
    print('No cursor found')
    return
  end

  if cursor:type() ~= 'string_fragment' then
    print('Cursor is not a string_fragment')
    return
  end

  local parsed_cursor = vim.treesitter.get_node_text(cursor, bufnr)

  -- Get lsp clients and find tailwind
  local clients = vim.lsp.get_clients()

  local tw = nil

  for _, client in pairs(clients) do
    if client.name == 'tailwindcss' then tw = client end
  end

  if tw == nil then
    print('No tailwindcss client found')
    return
  end

  local results = {
    '.test {',
  }

  local range = { vim.treesitter.get_node_range(cursor) }
  local init_col = range[2]
  local init_row = range[1]

  local classes = mysplit(parsed_cursor, ' ', init_col, init_row)

  -- print(vim.inspect(classes))
  local index = 0
  local longest = 0

  for _, class in ipairs(classes) do
    tw.request('textDocument/hover', {
      textDocument = vim.lsp.util.make_text_document_params(),
      position = {
        line = class.row,
        -- Only this
        character = class.col, --range[2]
      },
    }, function(err, result, ctx, config)
      index = index + 1

      if err then
        print('Error getting tailwind config')
        return
      end

      -- print(vim.inspect(result.contents))
      if not result then
        print('No result found')
        return
      end
      local pre_text = result.contents.value
      local extracted = vim.split(pre_text, '\n')

      table.remove(extracted, 1)
      table.remove(extracted, #extracted)

      for _, value in ipairs(extracted) do
        table.insert(results, #results + 1, value)

        if value:len() > longest then longest = #value end
      end

      if index == #classes then
        table.insert(results, #results + 1, '}')
        local height = #results + 1

        vim.lsp.util.open_floating_preview(results, 'css', {
          border = rvim.ui.current.border,
          width = longest,
          height = height,
        })
      end
    end, bufnr)
  end
end

rvim.command('TailwindClasses', function() tailwind_classes() end)

map('n', '<localleader>lt', '<cmd>TailwindClasses<cr>')
