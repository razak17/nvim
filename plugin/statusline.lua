if not ar then return end

if
  ar.none
  or not ar.config.ui.statusline.enable
  or (ar.config.ui.statusline.variant ~= 'local' and not ar.plugins.minimal)
then
  return
end

local fmt = string.format
local stl = require('ar.statusline')

--------------------------------------------------------------------------------
-- Statusline with no plugin
-- @see: https://github.com/shivambegin/Neovim/blob/main/lua/config/statusline.lua
--------------------------------------------------------------------------------
ar.highlight.plugin('NativeStatuslineHl', {
  {
    StatusLine = {
      bg = { from = 'CursorLine', alter = -0.3 },
      fg = { from = 'Normal' },
    },
  },
  { StatusLineBar = { fg = { from = 'Directory' }, bold = true } },
  { StatusLineMode = { fg = { from = 'Special' } } },
  { StatusLineMedium = { fg = { from = 'Normal' } } },
  { StatusLineMacroRecording = { fg = 'orange' } },
  { StatusLineMacroExecuting = { fg = 'lightgreen' } },
  { StatusLineLspActive = { fg = { from = 'Directory' }, bold = true } },
  { StatusLineLspError = { fg = { from = 'ErrorMsg' } } },
  { StatusLineLspWarn = { fg = { from = 'WarnMsg' } } },
  { StatusLineLspHint = { fg = { from = 'DiagnosicHint' } } },
  { StatusLineLspInfo = { fg = { from = 'DiagnosicInfo' } } },
  { StatusLineLspMessages = { fg = { from = 'Comment' } } },
  { StatusLineGitBranch = { fg = 'yellowgreen' } },
  { StatusLineGitAhead = { link = 'StatusLineGitBranch' } },
  { StatusLineGitBehind = { link = 'StatusLineLspError' } },
  { StatusLineVirtualEnv = { fg = { from = 'DiagnosticSignHint' } } },
  { StatusLineGitDiffAdded = { fg = 'yellowgreen' } },
  { StatusLineGitDiffChanged = { fg = { from = 'WarningMsg' } } },
  { StatusLineGitDiffRemoved = { fg = { from = 'StatusLineLspError' } } },
  { StatusLineLazyUpdates = { fg = { from = 'WarningMsg' } } },
})

-- LSP clients attached to buffer
local function lsp_clients()
  local current_buf = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ bufnr = current_buf })
  if next(clients) == nil then return '' end

  local c = {}
  for _, client in pairs(clients) do
    table.insert(c, client.name)
  end
  return ' 󰌘 ' .. table.concat(c, '|')
end

--- @return string
local function filename()
  local file_name = vim.api.nvim_buf_get_name(0)
  local file_size = stl.file_size()
  local pretty_path = require('ar.pretty_path').pretty_path()
  local dir = ''
  local name = ''
  if type(pretty_path) == 'table' then
    dir, name = pretty_path.dir, pretty_path.name
  end
  if file_name == '' then return '' end
  local full = ''
  if file_name ~= '' and dir ~= '' then
    full = full .. string.format(' %%#Comment#%s%%*', dir)
  end
  if file_name ~= '' and name ~= '' then
    local space = dir == '' and ' ' or ''
    full = full .. string.format('%s%%#StatusLineMedium#%s%%*', space, name)
  end
  return full .. string.format('%%#Comment#%s%%*', file_size)
end

--- @param severity integer
--- @return integer
local function get_lsp_diagnostics_count(severity)
  if not rawget(vim, 'lsp') then return 0 end

  local count = vim.diagnostic.count(0, { serverity = severity })[severity]
  if count == nil then return 0 end

  return count
end

--- @param type string
--- @return integer
local function get_git_diff(type)
  local gsd = vim.b.gitsigns_status_dict
  if gsd and gsd[type] then return gsd[type] end

  return 0
end

local vim_mode = { mode = nil, hl = nil }

local function generate_mode_hl(mode)
  local mode_to_str = mode and stl.mode_to_str[mode]
  local hl_name = 'StatusBorderActive' .. mode_to_str
  vim.api.nvim_set_hl(0, hl_name, { fg = stl.mode_colors[mode:sub(1, 1)] })
  return hl_name
end

ar.augroup('NativeStatuslineMode', {
  event = { 'ModeChanged', 'VimEnter' },
  pattern = '*',
  command = function()
    local mode = vim.fn.mode(1)
    vim_mode.mode = stl.mode_to_str[mode]
    vim_mode.hl = generate_mode_hl(mode)
    vim.cmd.redrawstatus()
  end,
})

--- @return string
local function bar() return string.format('%%#%s#▊%%*', vim_mode.hl) end

--- @return string
local function python_env()
  local virtual_env = stl.python_env()
  if virtual_env == '' then return '' end
  return string.format('%%#StatusLineVirtualEnv# %s%%*', virtual_env)
end

--- @return string
local function lazy()
  if not ar.has('lazy.nvim') then return '' end
  local updates = stl.lazy_updates()
  return string.format('%%#StatusLineLazyUpdates# %s%%*', updates)
end

--- @return string
local function lsp_active()
  if not rawget(vim, 'lsp') then return '' end

  local current_buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = current_buf })

  local space = '%#StatusLineMedium# %*'

  if #clients > 0 then
    return space
      .. '%#StatusLineLspActive#%*'
      .. space
      .. '%#StatusLineMedium#LSP%*'
  end

  return ''
end

--- @return string
local function diagnostics_error()
  local count = get_lsp_diagnostics_count(vim.diagnostic.severity.ERROR)
  if count > 0 then
    return string.format('%%#StatusLineLspError#  %s%%*', count)
  end
  return ''
end

--- @return string
local function diagnostics_warn()
  local count = get_lsp_diagnostics_count(vim.diagnostic.severity.WARN)
  if count > 0 then
    return string.format('%%#StatusLineLspWarn#  %s%%*', count)
  end
  return ''
end

--- @return string
local function diagnostics_hint()
  local count = get_lsp_diagnostics_count(vim.diagnostic.severity.HINT)
  if count > 0 then
    return string.format('%%#StatusLineLspHint# 󰌵 %s%%*', count)
  end
  return ''
end

--- @return string
local function diagnostics_info()
  local count = get_lsp_diagnostics_count(vim.diagnostic.severity.INFO)
  if count > 0 then
    return string.format('%%#StatusLineLspInfo#  %s%%*', count)
  end
  return ''
end

--- @class LspProgress
--- @field msg string?
local lsp_progress = { msg = nil }

ar.augroup('NativeStatuslineLspProgress', {
  event = 'LspProgress',
  desc = 'Update LSP progress in statusline',
  pattern = { 'begin', 'report', 'end' },
  command = function(args)
    local progress = stl.lsp_progress.handle(args)
    lsp_progress.msg = progress.message
    if progress.is_done then lsp_progress.msg = nil end
    vim.defer_fn(function() vim.cmd.redrawstatus() end, 500)
  end,
})

--- @return string
local function lsp_status()
  if not rawget(vim, 'lsp') then return '' end
  if not lsp_progress.msg or vim.o.columns < 120 then return '' end
  return string.format('%%#StatusLineLspMessages#%s%%* ', lsp_progress.msg)
end

--- @return string
local function git_diff_added()
  local added = get_git_diff('added')
  if added > 0 then
    return string.format('%%#StatusLineGitDiffAdded#  %s%%*', added)
  end
  return ''
end

--- @return string
local function git_diff_changed()
  local changed = get_git_diff('changed')
  if changed > 0 then
    return string.format('%%#StatusLineGitDiffChanged#  %s%%*', changed)
  end
  return ''
end

--- @return string
local function git_diff_removed()
  local removed = get_git_diff('removed')
  if removed > 0 then
    return string.format('%%#StatusLineGitDiffRemoved#  %s%%*', removed)
  end
  return ''
end

local function git_status()
  local remote_status = require('ar.git_status').get()
  if remote_status == '' then return '' end
  local parts = vim.split(remote_status, ' ', { trimempty = true })
  local branch =
    fmt('%%#StatusLineGitBranch# %s%%*', stl.pretty_branch(parts[1]))
  local behind = fmt(' %%#StatusLineMedium#%s%%*', parts[2])
  if parts[2] ~= '0' then
    behind = fmt(' %%#StatusLineGitBehind#%s%%*', parts[2])
  end
  local ahead = fmt(' %%#StatusLineMedium#%s%%*', parts[3])
  if parts[3] ~= '0' then
    ahead = fmt(' %%#StatusLineGitAhead#%s%%*', parts[3])
  end
  return ' ' .. branch .. behind .. ahead
end

--- @return string
local function git_diff()
  local full = ''

  local added = git_diff_added()
  if added ~= '' then full = full .. added end

  local removed = git_diff_removed()
  if removed ~= '' then full = full .. removed end

  local changed = git_diff_changed()
  if changed ~= '' then full = full .. changed end

  return ' ' .. full .. ' '
end

--- @return string
local function location()
  local loc = stl.location()

  return string.format('%%#StatusLineMedium#%s%% %%*', loc)
end

--- @param hlgroup string
local function formatted_filetype(hlgroup)
  local filetype = vim.bo.filetype or vim.fn.expand('%:e', false)
  return string.format('%%#%s# %s %%*', hlgroup, filetype)
end

local function filetype()
  return string.format(' {ft:%s}', vim.bo.filetype):lower()
end

local function search_matches()
  if vim.v.hlsearch == 0 then return '' end
  return stl.search_matches()
end

local function macro()
  if vim.fn.reg_recording() ~= '' then
    return string.format('%%#StatusLineMacroRecording#%s%% %%*', 'REC')
  end
  if vim.fn.reg_executing() ~= '' then
    return string.format('%%#StatusLineMacroExecuting#%s%% %%*', 'PLAY')
  end
  return ''
end

StatusLine = {}

local readeable_filetypes = {
  ['qf'] = true,
  ['help'] = true,
  ['tsplayground'] = true,
}

StatusLine.render = function()
  local mode_str = vim.api.nvim_get_mode().mode
  if mode_str == 't' or mode_str == 'nt' then
    return table.concat({
      bar(),
      '%=',
      '%=',
      location(),
      bar(),
    })
  end

  if vim.bo.ft == '' then return table.concat({ '%#Normal#%' }) end

  if readeable_filetypes[vim.bo.filetype] or vim.o.modifiable == false then
    return table.concat({
      bar(),
      formatted_filetype('StatusLineMode'),
      '%=',
      '%=',
      location(),
      bar(),
    })
  end

  local statusline = {
    bar(),
    git_status(),
    filename(),
    git_diff(),
    diagnostics_error(),
    diagnostics_warn(),
    diagnostics_info(),
    diagnostics_hint(),
    '%=',
    '%=',
    '%S ',
    lsp_status(),
    macro(),
    search_matches(),
    lsp_active(),
    python_env(),
    lazy(),
    filetype(),
    lsp_clients(),
    location(),
    bar(),
  }

  return table.concat(statusline)
end

vim.opt.statusline = '%!v:lua.StatusLine.render()'

ar.augroup('NativeStatusline', {
  event = { 'VimEnter' },
  command = function(args)
    local decs = ar.ui.decorations.get({
      ft = vim.bo[args.buf].ft,
      fname = vim.fn.bufname(args.buf),
      setting = 'statusline',
    })
    if vim.bo.ft == '' and args.match == '' then
      stl.intro_statusline(args.buf)
      return
    end
    if not decs or ar.falsy(decs) then return end
    if decs.ft == false or decs.fname == false then
      stl.intro_statusline(args.buf)
    end
  end,
})
