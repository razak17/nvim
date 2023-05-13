---@diagnostic disable: duplicate-doc-param missing-return

if not rvim or not rvim.ui.winbar.enable or vim.env.RVIM_PLUGINS_ENABLED == '0' then return end
local navic_loaded, navic = rvim.pcall(require, 'nvim-navic')
local devicons_loaded, devicons = rvim.pcall(require, 'nvim-web-devicons')

local str = require('user.strings')
local section, spacer, display = str.section, str.spacer, str.display

local fn, api, falsy, lsp_hls = vim.fn, vim.api, rvim.falsy, rvim.ui.lsp.highlights
local icons, decorations, highlight = rvim.ui.icons.misc, rvim.ui.decorations, rvim.highlight

local space = ' '
local dir_separator = icons.chevron_right
local separator = icons.triangle
local ellipsis = icons.ellipsis

--- A mapping of each winbar items ID to its path
---@type (string|{start: {line: integer, character: integer}})[]
local state = {}

local hls = {
  separator = 'WinbarDirectory',
  inactive = 'NonText',
  normal = 'Winbar',
  crumb = 'WinbarCrumb',
}

highlight.plugin('winbar', {
  { [hls.normal] = { bold = false } },
  { [hls.crumb] = { bold = false } },
  { [hls.separator] = { inherit = 'Directory' } },
})

---@param id number
function rvim.ui.winbar.click(id)
  if not id then return end
  local item = state[id]
  if type(item) == 'string' then vim.cmd.edit(item) end
  if type(item) == 'table' and item.start then
    api.nvim_win_set_cursor(fn.getmousepos().winid, { item.start.line, item.start.character })
  end
end

local function breadcrumbs()
  local empty_state = {
    { { separator, hls.separator }, { space }, { ellipsis, hls.inactive } },
    priority = 0,
  }
  if not navic_loaded or not navic.is_available() then return { empty_state } end
  local ok, data = pcall(navic.get_data)
  if not ok or falsy(data) then return { empty_state } end
  return rvim.map(function(crumb, index)
    local priority = #state + #data - index
    state[priority] = crumb.scope
    return {
      {
        { separator, hls.separator },
        { space },
        { crumb.icon, lsp_hls[crumb.type] or hls.inactive },
        { space },
        { crumb.name, hls.crumb, max_size = 35 },
      },
      priority = priority,
      id = priority,
      click = 'v:lua.rvim.ui.winbar.click',
    }
  end, data)
end

---@param current_win integer
---@return string
function rvim.ui.winbar.render(current_win)
  state = {}

  local w1 = section:new(spacer(1))
  local w2 = nil

  local bufname = api.nvim_buf_get_name(api.nvim_get_current_buf())
  if falsy(bufname) then return w1 + section:new({ { { '[No name]', hls.normal } }, priority = 0 }) end

  local use_relative_path = rvim.ui.winbar.relative_path
  local filepath = fn.fnamemodify(bufname, ':t')
  if use_relative_path then filepath = fn.fnamemodify(bufname, ':p:.') end

  local icon, color = rvim.ui.codicons.documents.default_folder, 'DevIconDefault'
  if rvim.ui.winbar.file_icon then
    if devicons_loaded then
      local devicon, devicon_color = devicons.get_icon(vim.fn.expand('%:t'))
      if devicon ~= nil and devicon_color ~= nil then
        icon, color = devicon, devicon_color
      end
    end
    w2 = section:new({ { { icon, color } }, priority = 0 })
  end

  local parts = vim.split(filepath, '/')
  if use_relative_path then
    local empty_string = rvim.find_string(parts, '')
    if empty_string then
      for _ = 1, 3 do
        table.remove(parts, 1)
      end
    end
  end

  local wn = rvim.map(function(part, index)
    local priority = (#parts - (index - 1)) * 2
    local is_last = index == #parts
    state[priority] = table.concat(vim.list_slice(parts, 1, index), '/')
    return {
      { { part, 'Winbar' }, not is_last and { ' ' .. dir_separator, hls.separator } or nil },
      id = priority,
      priority = priority,
      click = 'v:lua.rvim.ui.winbar.click',
    }
  end, parts)
  local win = api.nvim_get_current_win()
  local winbar = w1 + w2 + section:new(unpack(wn))
  if win == current_win then winbar = section:new(unpack(winbar)) + section:new(unpack(breadcrumbs())) end
  return display({ winbar }, api.nvim_win_get_width(win))
end

local function set_winbar()
  local current_win = api.nvim_get_current_win()
  rvim.foreach(function(w)
    local buf, win = vim.bo[api.nvim_win_get_buf(w)], vim.wo[w]
    if vim.t[0].diff_view_initialized then return end

    local bt, ft, is_diff = buf.buftype, buf.filetype, win.diff
    local decor = decorations.get({ ft = ft, bt = bt, setting = 'winbar' })
    if decor.ft == 'ignore' or decor.bt == 'ignore' then return end

    local normal_win = falsy(fn.win_gettype(api.nvim_win_get_number(w)))

    if normal_win and not decor.ft and bt == '' and ft ~= '' and not is_diff then
      win.winbar = ('%%{%%v:lua.rvim.ui.winbar.render(%d)%%}'):format(current_win)
    elseif is_diff then
      win.winbar = nil
    end
  end, api.nvim_tabpage_list_wins(0))
end

rvim.augroup('AttachWinbar', {
  event = { 'TabEnter', 'BufEnter', 'WinClosed' },
  desc = 'Toggle winbar',
  command = set_winbar,
})

local function toggle_relative_path()
  local current = rvim.ui.winbar.relative_path
  rvim.ui.winbar.relative_path = not current
  rvim.ui.notify(string.format('%s %s %s', 'winbar', 'relative path', rvim.bool2str(not current)))
end

map('n', '<leader>op', toggle_relative_path, { desc = 'winbar: toggle relative path' })
