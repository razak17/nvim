local enabled = ar_config.plugin.custom.remove_comments.enable
local ts_avilable = ar.is_available('nvim-treesitter')

if not ar or ar.none or not enabled or not ts_avilable then return end

local api = vim.api
local ts = vim.treesitter
local parsers = require('nvim-treesitter.parsers')

local queries = {
  config = {
    javascript = [[ (comment) @comment ]],
    typescript = [[ (comment) @comment ]],
    java = [[
      (line_comment) @comment
      (block_comment) @comment
    ]],
    lua = [[ (comment) @comment ]],
    python = [[ (comment) @comment ]],
    go = [[ (comment) @comment ]],
    c = [[
      (line_comment) @comment
      (block_comment) @comment
    ]],
    cpp = [[
      (line_comment) @comment
      (block_comment) @comment
    ]],
    rust = [[ (line_comment) @comment ]],
    html = [[ (comment) @comment ]],
    css = [[ (comment) @comment ]],
    yaml = [[ (comment) @comment ]],
    toml = [[ (comment) @comment ]],
    bash = [[ (comment) @comment ]],
    sh = [[ (comment) @comment ]],
  },
}

-- https://github.com/KashifKhn/nvim-remove-comments/blob/eae2fda8969b7ba31137d8c520a13b3731eb9cfa/lua/nvim-remove-comments/core.lua#L7
local function remove_comments()
  local bufnr = api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  if not parsers.has_parser(ft) then return end

  local parser = parsers.get_parser(bufnr, ft)
  if not parser then return end

  local root = parser:parse()[1]:root()
  local query_str = queries[ft]
  local query = ts.query.parse(ft, query_str or [[ (comment) @comment ]])

  local lines_to_delete = {}

  for _, node in query:iter_captures(root, bufnr, 0, -1) do
    local srow, scol, erow, ecol = node:range()
    local lines = api.nvim_buf_get_lines(bufnr, srow, erow + 1, false)

    if srow == erow then
      local line = lines[1]

      if scol == 0 and ecol == #line then
        lines_to_delete[srow] = true
      else
        local before = line:sub(1, scol)
        local after = line:sub(ecol + 1)
        api.nvim_buf_set_lines(
          bufnr,
          srow,
          srow + 1,
          false,
          { before .. after }
        )
      end
    else
      for i = srow, erow do
        lines_to_delete[i] = true
      end
    end
  end

  local rows = {}
  for row in pairs(lines_to_delete) do
    table.insert(rows, row)
  end
  table.sort(rows, function(a, b) return a > b end)

  for _, row in ipairs(rows) do
    api.nvim_buf_set_lines(bufnr, row, row + 1, false, {})
  end
end

ar.command('RemoveComments', remove_comments, {
  desc = 'Remove comments from the current buffer',
  nargs = 0,
})

ar.add_to_select_menu('command_palette', {
  ['Remove Comments'] = 'RemoveComments',
})
