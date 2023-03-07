if not rvim then return end

local api = vim.api

local conceal_html_class = function(bufnr)
  local namespace = api.nvim_create_namespace('HTMLClassConceal')
  local language_tree = vim.treesitter.get_parser(bufnr, 'html')
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()

  local query = vim.treesitter.parse_query(
    'html',
    [[
    ((attribute
        (attribute_name) @att_name (#eq? @att_name "class")
        (quoted_attribute_value (attribute_value) @class_value) (#set! @class_value conceal "…")))
    ]]
  )

  for _, captures, metadata in query:iter_matches(root, bufnr, root:start(), root:end_()) do
    local start_row, start_col, end_row, end_col = captures[2]:range()
    api.nvim_buf_set_extmark(bufnr, namespace, start_row, start_col, {
      end_line = end_row,
      end_col = end_col,
      conceal = metadata[2].conceal,
    })
  end
end

rvim.augroup('HTMLClassConceal', {
  event = { 'BufEnter', 'BufWritePost', 'TextChanged', 'InsertLeave' },
  pattern = { '*.html', '*.svelte', '*.astro' },
  command = function() conceal_html_class(api.nvim_get_current_buf()) end,
})
