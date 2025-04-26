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

return M
