---@diagnostic disable: undefined-field
local api, opt_l = vim.api, vim.opt_local
local l = vim.log.levels
local scheme_switcher = require('ar.scheme_switcher')
local colorscheme = scheme_switcher.get_current_colorscheme()
local M = {}

local config = {
  alpha_green = {
    enabled = false,
    highlights = {
      bg = '#000000',
      fg = '#00ff00',
    },
  },
  color_my_pencils = {
    enabled = false,
    highlights = {
      ColorColumn = { bg = 'cyan' },
      CursorLine = { bg = '#1d7c78', fg = 'black' },
      CursorLineNr = { fg = '#aed75f' },
      LineNr = { fg = '#4dd2dc' },
      VertSplit = { fg = '#4dd2dc' },
      WinSeparator = { fg = '#4dd2dc' },
      StatusLine = { bg = '#000000' },
      Normal = { bg = 'none' },
      Winbar = { bg = 'none' },
      WinbarNC = { bg = 'none' },
      netrwDir = { fg = '#aeacec' },
      qfFileName = { fg = '#aed75f' },
    },
  },
  toggle_guides = { enabled = true },
}

local function mappings_notify(msg, type)
  type = type or l.INFO
  vim.schedule(function() vim.notify(msg, type, { title = 'UI Toggles' }) end)
end

---@param opt string
function M.toggle_opt(opt)
  local prev = vim.api.nvim_get_option_value(opt, {})
  local value
  if type(prev) == 'boolean' then value = not prev end
  vim.wo[opt] = value
  mappings_notify(string.format('%s %s', opt, ar.bool2str(vim.wo[opt])))
end

--- Toggle laststatus=3|2|0
function M.toggle_statusline()
  local laststatus = vim.opt.laststatus:get()
  local status
  if laststatus == 0 then
    vim.opt.laststatus = 2
    status = 'local'
  elseif laststatus == 2 then
    vim.opt.laststatus = 3
    status = 'global'
  elseif laststatus == 3 then
    vim.opt.laststatus = 0
    status = 'off'
  end
  mappings_notify(string.format('statusline %s', status))
end

--- Toggle conceal=2|0
function M.toggle_conceal_level()
  vim.opt_local.conceallevel = opt_l.conceallevel:get() == 0 and 2 or 0
  mappings_notify(
    string.format('conceal %s', ar.bool2str(opt_l.conceallevel:get() == 2))
  )
end

--- Toggle conceal cursor=n|''
function M.toggle_conceal_cursor()
  vim.opt_local.concealcursor = ar.falsy(opt_l.concealcursor:get()) and 'nv'
    or ''
  mappings_notify(
    string.format(
      'conceal cursor %s',
      ar.bool2str(ar.falsy(opt_l.concealcursor:get()))
    )
  )
end

function M.alpha_green()
  local enabled = config.alpha_green.enabled
  vim.cmd('hi clear')
  if enabled then
    vim.cmd.colorscheme(colorscheme or 'default')
  else
    local hl = config.alpha_green.highlights
    for hl_group, attrs in pairs(vim.api.nvim_get_hl(0, {})) do
      if attrs.fg then attrs.fg = hl.fg end
      if attrs.bg then attrs.bg = hl.bg end
      api.nvim_set_hl(0, hl_group, attrs)
    end
    api.nvim_set_hl(0, 'Visual', { bg = '#222222' })
    api.nvim_set_hl(0, 'CursorLine', { bg = '#002200' })
    api.nvim_set_hl(0, 'ColorColumn', { bg = hl.fg })
  end
  config.alpha_green.enabled = not enabled
end

function M.color_my_pencils()
  local enabled = config.color_my_pencils.enabled
  vim.cmd('hi clear')
  if enabled then
    vim.cmd.colorscheme(colorscheme or 'default')
  else
    for hl, value in pairs(config.color_my_pencils.highlights) do
      if value.fg then api.nvim_set_hl(0, hl, { fg = value.fg }) end
      if value.bg then api.nvim_set_hl(0, hl, { bg = value.bg }) end
    end
  end
  config.color_my_pencils.enabled = not enabled
end

function M.toggle_guides()
  local enabled = config.toggle_guides.enabled
  ar.config.plugin.main.numbers.enable = not enabled
  local wins = api.nvim_list_wins()
  for _, win in ipairs(wins) do
    vim.wo[win].number, vim.wo.relativenumber = not enabled, not enabled
    vim.wo[win].signcolumn = enabled and 'no' or 'yes'
    vim.wo[win].colorcolumn = enabled and '800' or '80'
  end
  config.toggle_guides.enabled = not enabled
end

return M
