local enabled = ar.config.plugin.custom.comment.enable

if not ar or ar.none or not enabled then return end

local fn, api = vim.fn, vim.api

-- https://github.com/chrisgrieser/.config/blob/main/nvim/lua/personal-plugins/comment.lua?plain=1#L1

local formatter_want_padding = { 'python', 'swift', 'toml' }

local M = {}

---@return string?
local function get_comment_str()
  local com_str = vim.bo.commentstring
  if not com_str or com_str == '' then
    vim.notify(
      'No commentstring for ' .. vim.bo.ft,
      vim.log.levels.WARN,
      { title = 'Comment' }
    )
    return
  end
  return com_str
end

-- appends a horizontal line, with the language's comment syntax,
-- correctly indented and padded
function M.comment_hr()
  local com_str = get_comment_str()
  if not com_str then return end
  local start_ln = api.nvim_win_get_cursor(0)[1]

  -- determine indent
  local ln = start_ln
  local line, indent
  repeat
    line = api.nvim_buf_get_lines(0, ln - 1, ln, true)[1]
    indent = line:match('^%s*')
    ln = ln - 1
  until line ~= '' or ln == 0

  -- determine hr_length
  local indent_length = vim.bo.expandtab and #indent or #indent * vim.bo.tabstop
  local com_str_length = #(com_str:format(''))
  local textwidth = vim.o.textwidth > 0 and vim.o.textwidth or 80
  local hr_length = textwidth - (indent_length + com_str_length)

  -- construct HR
  local hr_char = com_str:find('%-') and '-' or '─'
  local hr = hr_char:rep(hr_length)
  local hr_with_comment = com_str:format(hr)

  -- filetype-specific considerations
  if not vim.list_contains(formatter_want_padding, vim.bo.ft) then
    hr_with_comment = hr_with_comment:gsub(' ', hr_char)
  end
  local full_line = indent .. hr_with_comment
  if vim.bo.ft == 'markdown' then full_line = '---' end

  -- append lines & move
  api.nvim_buf_set_lines(0, start_ln, start_ln, true, { full_line, '' })
  api.nvim_win_set_cursor(0, { start_ln + 1, #indent })
end

function M.duplicate_line_as_comment()
  local com_str = get_comment_str()
  if not com_str then return end
  local lnum, col = unpack(api.nvim_win_get_cursor(0))
  local cur_line = api.nvim_get_current_line()
  local indent, content = cur_line:match('^(%s*)(.*)')
  local commented_line = indent .. com_str:format(content)
  api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { commented_line, cur_line })
  api.nvim_win_set_cursor(0, { lnum + 1, col })
end

-- simplified implementation of neogen.nvim
-- (reason: lsp usually provides better prefills for docstrings)
function M.docstring()
  local ok, ts_move = pcall(require, 'nvim-treesitter-textobjects.move')
  if not (ok and ts_move) then
    vim.notify(
      '`nvim-treesitter-textobjects` not installed.',
      vim.log.levels.WARN
    )
    return
  end
  ts_move.goto_previous_start('@function.outer', 'textobjects')

  local ft = vim.bo.filetype
  local indent = api.nvim_get_current_line():match('^%s*')
  local ln = api.nvim_win_get_cursor(0)[1]

  if ft == 'python' then
    indent = indent .. (' '):rep(4)
    api.nvim_buf_set_lines(0, ln, ln, false, { indent .. ('"'):rep(6) })
    api.nvim_win_set_cursor(0, { ln + 1, #indent + 3 })
    vim.cmd.startinsert()
  elseif ft == 'javascript' then
    vim.cmd.normal({ 't)', bang = true }) -- go to parameter, since cursor has to be on diagnostic for code action
    vim.lsp.buf.code_action({
      filter = function(action)
        return action.title == 'Infer parameter types from usage'
      end,
      apply = true,
    })
    -- goto docstring (deferred, so code action can finish first)
    vim.defer_fn(function()
      api.nvim_win_set_cursor(0, { ln + 1, 0 })
      vim.cmd.normal({ 't)', bang = true })
    end, 100)
  elseif ft == 'typescript' then
    -- add TSDoc
    api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { indent .. '/**  */' })
    api.nvim_win_set_cursor(0, { ln, #indent + 4 })
    vim.cmd.startinsert()
  elseif ft == 'lua' then
    local params = api.nvim_get_current_line():match('function.*%((.*)%)$')
    if not params then return end
    local luadoc = vim.tbl_map(
      function(param) return ('%s---@param %s any'):format(indent, param) end,
      vim.split(params, ', ?')
    )
    api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, luadoc)
    -- goto 1st param type & edit it
    api.nvim_win_set_cursor(0, { ln, #luadoc[1] })
    vim.cmd.normal({ '"_ciw', bang = true })
    vim.cmd.startinsert({ bang = true })
  else
    vim.notify(
      ft .. ' is not supported.',
      vim.log.levels.WARN,
      { title = 'docstring' }
    )
  end
end

--------------------------------------------------------------------------------

---@param where "eol"|"above"|"below"
function M.add_comment(where)
  local com_str = get_comment_str()
  if not com_str then return end
  local lnum = api.nvim_win_get_cursor(0)[1]

  -- above/below: add empty line and move to it
  if where == 'above' or where == 'below' then
    if where == 'above' then lnum = lnum - 1 end
    api.nvim_buf_set_lines(0, lnum, lnum, true, { '' })
    lnum = lnum + 1
    api.nvim_win_set_cursor(0, { lnum, 0 })
  end

  -- determine comment behavior
  local place_holder_at_end = com_str:find('%%s$') ~= nil
  local line = api.nvim_get_current_line()
  local emptyLine = line == ''

  -- if empty line, add indent of first non-blank line after cursor
  local indent = ''
  if emptyLine then
    local i = lnum
    local last_line = api.nvim_buf_line_count(0)
    while fn.getline(i) == '' and i < last_line do
      i = i + 1
    end
    indent = fn.getline(i):match('^%s*')
  end
  local spacing = vim.list_contains(formatter_want_padding, vim.bo.ft) and '  '
    or ' '
  local new_line = emptyLine and indent or line .. spacing

  -- write line
  com_str = com_str:gsub('%%s', ''):gsub(' *$', '') .. ' '
  api.nvim_set_current_line(new_line .. com_str)

  -- move cursor
  if place_holder_at_end then
    vim.cmd.startinsert({ bang = true })
  else
    local placeholder_pos = vim.bo.commentstring:find('%%s') - 1
    local new_cursor_pos = { lnum, #new_line + placeholder_pos }
    api.nvim_win_set_cursor(0, new_cursor_pos)
    vim.cmd.startinsert()
  end
end

-- stylua: ignore start
map('n', 'gcd', function() M.comment_hr() end, { desc = 'comment: horizontal divider' })
map('n', 'gcl', function() M.duplicate_line_as_comment() end, { desc = 'comment: duplicate line as comment' })
map('n', 'gcf', function() M.docstring() end, { desc = 'comment: function docstring' })
map('n', 'gcA', function() M.add_comment('eol') end, { desc = 'comment: append comment' })
map('n', 'gco', function() M.add_comment('below') end, { desc = 'comment: comment below' })
map('n', 'gcO', function() M.add_comment('above') end, { desc = 'comment: comment above' })

return M
