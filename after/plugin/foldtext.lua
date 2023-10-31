if not rvim or rvim.none then return end

local ts, api, opt = vim.treesitter, vim.api, vim.opt

-- Copied from https://www.reddit.com/r/neovim/comments/16sqyjz/finally_we_can_have_highlighted_folds/
function rvim.ui.foldtext()
  local pos = vim.v.foldstart
  local line = api.nvim_buf_get_lines(0, pos - 1, pos, false)[1]
  local lang = ts.language.get_lang(vim.bo.filetype)
  local parser = ts.get_parser(0, lang)
  local query = ts.query.get(parser:lang(), 'highlights')

  if not query then return vim.fn.foldtext() end

  local tree = parser:parse({ pos - 1, pos })[1]
  local result = {}
  local line_pos = 0
  local prev_range

  for id, node, _ in query:iter_captures(tree:root(), 0, pos - 1, pos) do
    local name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()
    if start_row == pos - 1 and end_row == pos - 1 then
      local range = { start_col, end_col }
      if start_col > line_pos then
        table.insert(result, { line:sub(line_pos + 1, start_col), 'Folded' })
      end
      line_pos = end_col
      local text = ts.get_node_text(node, 0)
      if
        prev_range ~= nil
        and range[1] == prev_range[1]
        and range[2] == prev_range[2]
      then
        result[#result] = { text, '@' .. name }
      else
        table.insert(result, { text, '@' .. name })
      end
      prev_range = range
    end
  end

  result[#result + 1] = { ' … ', 'Operator' }

  return result
end

local skip_foldexpr = {} ---@type table<number,boolean>
local skip_check = assert(vim.loop.new_check())

function rvim.ui.foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  -- still in the same tick and no parser
  if skip_foldexpr[buf] then return '0' end

  -- don't use treesitter folds for non-file buffers
  if vim.bo[buf].buftype ~= '' then return '0' end

  -- as long as we don't have a filetype, don't bother
  -- checking if treesitter is available (it won't)
  if vim.bo[buf].filetype == '' then return '0' end

  local ok = pcall(vim.treesitter.get_parser, buf)

  if ok then return vim.treesitter.foldexpr() end

  -- no parser available, so mark it as skip
  -- in the next tick, all skip marks will be reset
  skip_foldexpr[buf] = true
  skip_check:start(function()
    skip_foldexpr = {}
    skip_check:stop()
  end)
  return '0'
end

opt.foldtext = 'v:lua.rvim.ui.foldtext()'
opt.foldexpr = 'v:lua.rvim.ui.foldexpr()'
