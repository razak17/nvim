local api = vim.api

local M = {}

-- https://github.com/simifalaye/dotfiles/blob/main/roles/neovim/dots/.config/nvim/lua/plugins/cmp.lua#L35
function M.has_words_before()
  local line, col = (unpack or table.unpack)(api.nvim_win_get_cursor(0))
  return col ~= 0
    and api
        .nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match('%s')
      == nil
end

function M.get_color(entry, item)
  local entry_doc = entry
  if type(entry_doc) == 'table' then
    entry_doc = vim.tbl_get(entry or {}, 'completion_item', 'documentation')
  end

  if
    entry_doc
    and type(entry_doc) == 'string'
    and entry_doc:match('^#%x%x%x%x%x%x$')
  then
    local hl = 'hex-' .. entry_doc:sub(2)
    if #api.nvim_get_hl(0, { name = hl }) == 0 then
      api.nvim_set_hl(0, hl, { fg = entry_doc })
    end
    item.kind = ar.ui.icons.misc.block_medium
    item.kind_hl_group = hl
  end
  return item
end

return M
