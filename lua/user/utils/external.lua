local M = {
  tmux = {},
}

local u = require('zephyr.utils')
local fn = vim.fn
local fmt = string.format

--- Get the color of the current vim background and update tmux accordingly
---@param reset boolean?
function M.tmux.set_statusline(reset)
  -- TODO: we should correctly derive the previous bg value automatically
  local bg = reset and '#373d48' or u.get('Normal', 'bg')
  fn.jobstart(fmt('tmux set-option -g status-style bg=%s', bg))
end

local function fileicon()
  local name = fn.bufname()
  local icon, hl
  local loaded, devicons = rvim.safe_require('nvim-web-devicons')
  if loaded then
    icon, hl = devicons.get_icon(name, fn.fnamemodify(name, ':e'), { default = true })
  end
  return icon, hl
end

function M.title_string()
  local dir = fn.fnamemodify(fn.getcwd(), ':t')
  local icon, hl = fileicon()
  if not hl then return (icon or '') .. ' ' end
  local title_string = fmt('%s #[fg=%s]%s ', dir, u.get(hl, 'fg'), icon)
  local has_tmux = vim.env.TMUX ~= nil
  -- fn.jobstart(fmt("tmux set-titles-string '%s'", title_string))
  return has_tmux and title_string or dir .. ' ' .. icon
end

function M.tmux.clear_pane_title() fn.jobstart('tmux set-window-option automatic-rename on') end

function M.tmux.set_window_title()
  local session = fn.fnamemodify(vim.loop.cwd(), ':t') or 'Neovim'
  local window_title = fmt('%s', session)
  fn.jobstart(fmt("tmux rename-window '%s'", window_title))
end

return M
