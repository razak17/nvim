---@diagnostic disable: duplicate-doc-param missing-return

if not rvim or not rvim.ui.winbar.enable or not rvim.plugins.enable then return end
local navic_loaded, navic = pcall(require, 'nvim-navic')

local str = require('user.strings')

local fn, api = vim.fn, vim.api
local icons, decorations, highlight = rvim.ui.icons.ui, rvim.ui.decorations, rvim.highlight
local lsp_hl = rvim.ui.lsp.highlights
local component, empty = str.component, rvim.empty

local dir_separator = icons.chevron_right
local separator = icons.triangle
local ellipsis = icons.ellipsis

--- A mapping of each winbar items ID to its path
---@type (string|{start: {line: integer, character: integer}})[]
local state = {}

highlight.plugin('winbar', {
  { Winbar = { bold = false } },
  { WinbarNC = { bold = false } },
  { WinbarCrumb = { bold = false } },
  { WinbarIcon = { inherit = 'Function' } },
  { WinbarDirectory = { inherit = 'Directory' } },
})

---@param id number
---@param _ number number of clicks
---@param _ "l"|"r"|"m" the button clicked
---@param _ string modifiers
function rvim.ui.winbar.click(id, _, _, _)
  if not id then return end
  local item = state[id]
  if type(item) == 'string' then vim.cmd.edit(item) end
  if type(item) == 'table' and item.start then
    local win = fn.getmousepos().winid
    api.nvim_win_set_cursor(win, { item.start.line, item.start.character })
  end
end

local function breadcrumbs()
  local empty_state = { component(ellipsis, 'NonText', { priority = 0 }) }
  if not navic.is_available() then return empty_state end
  local ok, data = pcall(navic.get_data)
  if not ok or empty(data) then return empty_state end
  return rvim.map(function(crumb, index)
    local priority = #state + #data - index
    state[priority] = crumb.scope
    return component(crumb.name, 'WinbarCrumb', {
      priority = priority,
      id = priority,
      click = 'v:lua.rvim.ui.winbar.click',
      max_size = 35,
      prefix = {
        { index ~= 1 and separator or '', 'Directory' },
        { crumb.icon, lsp_hl[crumb.type] or 'NonText' },
      },
    })
  end, data)
end

---@return string
function rvim.ui.winbar.render()
  state = {}
  local winbar = {}
  local add = str.append(winbar)

  add(str.spacer(1))

  local bufname = api.nvim_buf_get_name(api.nvim_get_current_buf())
  if empty(bufname) then
    add(component('[No name]', 'Winbar', { priority = 0 }))
    return winbar
  end

  local filepath = fn.fnamemodify(bufname, ':t')
  if rvim.ui.winbar.use_relative_path then filepath = fn.fnamemodify(bufname, ':.') end

  local parts = vim.split(filepath, '/')
  local _, devicons = rvim.require('nvim-web-devicons')
  local icon, color = devicons.get_icon(vim.fn.expand('%:t'))
  if icon == nil and color == nil then
    icon = ''
    color = 'DevIconDefault'
  end
  rvim.foreach(function(part, index)
    local priority = (#parts - (index - 1)) * 2
    local show_icon = rvim.ui.winbar.use_file_icon and icon or nil
    local is_last = index == #parts
    local sep = is_last and separator or dir_separator
    state[priority] = table.concat(vim.list_slice(parts, 1, index), '/')
    add(component(part, 'Winbar', {
      id = priority,
      priority = priority,
      click = 'v:lua.rvim.ui.winbar.click',
      suffix = { { sep, 'Winbar' } },
      ---@diagnostic disable-next-line: assign-type-mismatch
      prefix = show_icon and { { icon, color } } or '',
    }))
  end, parts)
  if navic_loaded then add(unpack(breadcrumbs())) end
  return str.display(winbar, api.nvim_win_get_width(api.nvim_get_current_win()))
end

local function set_winbar()
  rvim.foreach(function(w)
    local buf, win = vim.bo[api.nvim_win_get_buf(w)], vim.wo[w]
    local bt, ft, is_diff = buf.buftype, buf.filetype, win.diff
    local ft_setting = decorations.get(ft, 'winbar', 'ft')
    local bt_setting = decorations.get(bt, 'winbar', 'bt')
    local ignored = ft_setting == 'ignore' or bt_setting == 'ignore'
    if not ignored then
      if
        not ft_setting
        and fn.win_gettype(api.nvim_win_get_number(w)) == ''
        and bt == ''
        and ft ~= ''
        and not is_diff
      then
        win.winbar = '%{%v:lua.rvim.ui.winbar.render()%}'
      elseif is_diff then
        win.winbar = nil
      end
    end
  end, api.nvim_tabpage_list_wins(0))
end

rvim.augroup('AttachWinbar', {
  event = { 'BufWinEnter', 'TabNew', 'TabEnter', 'BufEnter', 'WinClosed' },
  desc = 'Toggle winbar',
  command = set_winbar,
}, {
  event = 'User',
  pattern = { 'DiffviewDiffBufRead', 'DiffviewDiffBufWinEnter' },
  desc = 'Toggle winbar',
  command = set_winbar,
})
