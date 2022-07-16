---@diagnostic disable: duplicate-doc-param

local Log = require('user.core.log')
local ok, navic = pcall(require, 'nvim-navic')
if not ok then
  Log:debug('Failed to load nvim-navic')
  return
end

local devicons = require('nvim-web-devicons')
local highlights = require('zephyr.utils')
local utils = require('user.utils.statusline')
local component = utils.component
local component_raw = utils.component_raw
local empty = rvim.empty

local fn = vim.fn
local api = vim.api
local icons = rvim.style.icons.misc

local dir_separator = '/'
local separator = icons.arrow_right
local ellipsis = icons.ellipsis

--- A mapping of each winbar items ID to its path
--- @type table<string, string>
rvim.winbar_state = {}

---@param id number
---@param _ number number of clicks
---@param _ "l"|"r"|"m" the button clicked
---@param _ string modifiers
function rvim.winbar_click(id, _, _, _)
  if id then vim.cmd('edit ' .. rvim.winbar_state[id]) end
end

highlights.plugin('winbar', {
  Winbar = { bold = false },
  WinbarNC = { bold = false },
  WinbarCrumb = { bold = true },
  WinbarIcon = { inherit = 'Function' },
  WinbarDirectory = { inherit = 'Directory' },
})

local function breadcrumbs()
  local empty_state = { component(ellipsis, 'NonText', { priority = 0 }) }
  if not ok or not navic.is_available() then return empty_state end
  local navic_ok, location = pcall(navic.get_location)
  if not navic_ok or empty(location) then return empty_state end
  local win = api.nvim_get_current_win()
  return { component_raw(location, { priority = 1, win_id = win, type = 'winbar' }) }
end

---@return string
function rvim.ui.winbar()
  local winbar = {}
  local add = utils.winline(winbar)

  add(utils.spacer(1))

  local bufname = api.nvim_buf_get_name(api.nvim_get_current_buf())
  if empty(bufname) then return add(component('[No name]', 'Winbar', { priority = 0 })) end

  local parts = vim.split(fn.fnamemodify(bufname, ':.'), '/')
  local icon, color = devicons.get_icon(bufname, nil, { default = true })

  rvim.foreach(function(part, index)
    local priority = (#parts - (index - 1)) * 2
    local is_first = nil
    if rvim.ui.winbar_ft_icon then is_first = index == 1 end
    local is_last = index == #parts
    local sep = is_last and separator or dir_separator
    local hl = is_last and 'Winbar' or 'LineNr'
    local suffix_hl = is_last and 'WinbarDirectory' or 'LineNr'
    rvim.winbar_state[priority] = table.concat(vim.list_slice(parts, 1, index), '/')
    add(component(part, hl, {
      id = priority,
      priority = priority,
      click = 'v:lua.rvim.winbar_click',
      suffix = sep,
      suffix_color = suffix_hl,
      prefix = is_first and icon or nil,
      prefix_color = is_first and color or nil,
    }))
  end, parts)
  add(unpack(breadcrumbs()))
  return utils.display(winbar, api.nvim_win_get_width(api.nvim_get_current_win()))
end

local blocked = {
  'NeogitStatus',
  'NeogitCommitMessage',
  'toggleterm',
  'DressingInput',
  'dashboard',
  'TelescopePrompt',
  'sql',
}
local allowed = { 'toggleterm' }

rvim.augroup('AttachWinbar', {
  {
    event = { 'BufWinEnter', 'BufEnter', 'WinClosed' },
    desc = 'Toggle winbar',
    command = function()
      for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
        local buf = api.nvim_win_get_buf(win)
        if
          not vim.tbl_contains(blocked, vim.bo[buf].filetype)
          and empty(fn.win_gettype(win))
          and empty(vim.bo[buf].buftype)
          and not empty(vim.bo[buf].filetype)
        then
          vim.wo[win].winbar = '%{%v:lua.rvim.ui.winbar()%}'
        elseif not vim.tbl_contains(allowed, vim.bo[buf].filetype) then
          vim.wo[win].winbar = nil
        end
      end
    end,
  },
})
