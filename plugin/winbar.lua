if not ar then return end

if
  ar.none
  or not ar.config.ui.winbar.enable
  or ar.config.ui.winbar.variant ~= 'custom'
then
  return
end

-- Ref: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/options.lua?plain=1#L41

local config = {
  show_hostname = false,
  show_buffer_count = true,
  pretty_path = true,
}

ar.ui.winbar = {}

local api, fn, bo = vim.api, vim.fn, vim.bo
local decor = ar.ui.decorations

local function get_winbar_path()
  local full_path = fn.expand('%:p')
  return full_path:gsub(fn.expand('$HOME'), '~')
end

local function get_buffer_count() return #fn.getbufinfo({ buflisted = 1 }) end

function ar.ui.winbar.render()
  local filepath = api.nvim_buf_get_name(0)

  if bo.ft == '' and filepath == '' then return end

  if fn.win_gettype() == 'popup' then return end

  if bo.bt == 'terminal' then return end

  local home_replaced = get_winbar_path()
  local pretty_path = require('ar.pretty_path').pretty_path()
  local buffer_count = get_buffer_count()
  local host = fn.systemlist('hostname')[1]

  local left = '%#WinBar1#%m '
  local buf_count = '%#WinBar2#(' .. buffer_count .. ') '
  local file_path = '%#WinBar1#' .. home_replaced .. '%*%='
  if config.pretty_path and pretty_path ~= '' then
    file_path = '%#WinBar1#' .. pretty_path.dir .. pretty_path.name .. '%*%='
  end
  local hostname = '%#WinBar1#' .. host

  return table.concat({
    left,
    config.show_buffer_count and buf_count or '',
    file_path,
    config.show_hostname and hostname or '',
  }, '')
end

local function refresh_window(win)
  if not api.nvim_win_is_valid(win) then return end
  if api.nvim_win_get_config(win).relative ~= '' then return end

  local buf = api.nvim_win_get_buf(win)
  local d = decor.get({
    ft = bo[buf].ft,
    fname = fn.bufname(buf),
    setting = 'winbar',
  })

  if not d or ar.falsy(d) then
    local winbar = api.nvim_win_call(win, ar.ui.winbar.render)
    api.nvim_set_option_value('winbar', winbar or '', { win = win })
    return
  end

  if ar.falsy(d.ft) then
    api.nvim_set_option_value('winbar', '', { win = win })
  end
end

local refresh_pending = false
local function refresh_all_windows()
  if refresh_pending then return end
  refresh_pending = true

  vim.schedule(function()
    refresh_pending = false
    for _, win in ipairs(api.nvim_list_wins()) do
      refresh_window(win)
    end
  end)
end

ar.augroup('Winbar', {
  event = { 'BufEnter', 'FileType', 'FocusGained', 'TextChanged' },
  command = function() refresh_window(api.nvim_get_current_win()) end,
}, {
  event = { 'BufAdd', 'BufDelete', 'BufWipeout' },
  command = refresh_all_windows,
})
