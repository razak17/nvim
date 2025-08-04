local enabled = ar_config.plugin.custom.remove_comments.enable
local ts_avilable = ar.is_available('nvim-treesitter')

if not ar or ar.none or not enabled or not ts_avilable then return end

local api = vim.api

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

-- https://gist.github.com/kelvinauta/bf812108f3b68fa73de58e873c309805
local remove_comments = function()
  local ts = vim.treesitter
  local bufnr = api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local lang = ts.language.get_lang(ft) or ft

  local ok, parser = pcall(ts.get_parser, bufnr, lang)
  if not ok or parser == nil then
    return vim.notify('No parser for ' .. ft, vim.log.levels.WARN)
  end

  local tree = parser:parse()[1]
  local root = tree:root()
  local query_str = queries[ft]
  local query = ts.query.parse(lang, query_str or [[ (comment) @comment ]])

  local ranges = {}
  for _, node in query:iter_captures(root, bufnr, 0, -1) do
    table.insert(ranges, { node:range() })
  end

  table.sort(ranges, function(a, b)
    if a[1] == b[1] then return a[2] < b[2] end
    return a[1] > b[1]
  end)

  for _, r in ipairs(ranges) do
    vim.api.nvim_buf_set_text(bufnr, r[1], r[2], r[3], r[4], {})
  end
end

ar.command('RemoveComments', remove_comments, {
  desc = 'Remove comments from the current buffer',
  nargs = 0,
})

ar.add_to_select_menu(
  'command_palette',
  { ['Remove Comments'] = 'RemoveComments' }
)
