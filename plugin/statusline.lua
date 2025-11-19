if
  not ar
  or ar.none
  or not ar_config.ui.statusline.enable
  or (ar_config.ui.statusline.variant ~= 'local' and not ar.plugins.minimal)
then
  return
end

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
  { StatusLineLspActive = { fg = { from = 'Directory' }, bold = true } },
  { StatusLineLspError = { fg = { from = 'ErrorMsg' } } },
  { StatusLineLspWarn = { fg = { from = 'WarnMsg' } } },
  { StatusLineLspHint = { fg = { from = 'DiagnosicHint' } } },
  { StatusLineLspInfo = { fg = { from = 'DiagnosicInfo' } } },
  { StatusLineLspMessages = { fg = { from = 'Comment' } } },
  { StatusLineGitBranchIcon = { fg = { from = 'DiagnosticSignHint' } } },
  {
    StatusLineGitDiffAdded = {
      fg = { from = 'DiffAdd', attr = 'bg', alter = 2.2 },
    },
  },
  {
    StatusLineGitDiffChanged = {
      fg = { from = 'DiffChange', attr = 'bg', alter = 2.2 },
    },
  },
  { StatusLineGitDiffRemoved = { fg = { from = 'DiffDelete', attr = 'bg' } } },
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
  local fname = vim.fn.expand('%:t')
  if fname == '' then return '' end
  return ' ' .. fname .. ' '
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

local modes = {
  ['n'] = 'NORMAL',
  ['no'] = 'NORMAL',
  ['v'] = 'VISUAL',
  ['V'] = 'VISUAL LINE',
  [''] = 'VISUAL BLOCK',
  ['s'] = 'SELECT',
  ['S'] = 'SELECT LINE',
  [''] = 'SELECT BLOCK',
  ['i'] = 'INSERT',
  ['ic'] = 'INSERT',
  ['R'] = 'REPLACE',
  ['Rv'] = 'VISUAL REPLACE',
  ['c'] = 'COMMAND',
  ['cv'] = 'VIM EX',
  ['ce'] = 'EX',
  ['r'] = 'PROMPT',
  ['rm'] = 'MOAR',
  ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL',
  ['t'] = 'TERMINAL',
}
--- @return string
local function mode()
  local current_mode = vim.api.nvim_get_mode().mode
  return string.format(' %s', modes[current_mode]):upper()
end

--- @return string
local function python_env()
  if not rawget(vim, 'lsp') then return '' end

  local buf = vim.api.nvim_get_current_buf()
  local buf_clients = vim.lsp.get_clients({ bufnr = buf })
  if next(buf_clients) == nil then return '' end

  for _, client in pairs(buf_clients) do
    if client.name == 'pyright' or client.name == 'pylance' then
      local virtual_env = vim.env.VIRTUAL_ENV_PROMPT
      if virtual_env == nil then return '' end

      virtual_env = virtual_env:gsub('%s+', '')
      return string.format('%%#StatusLineMedium# %s%%*', virtual_env)
    end
  end

  return ''
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
local function diagnostics_warns()
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
--- @field client vim.lsp.Client?
--- @field kind string?
--- @field title string?
--- @field percentage integer?
--- @field message string?
local lsp_progress = {
  client = nil,
  kind = nil,
  title = nil,
  percentage = nil,
  message = nil,
}

ar.augroup('NativeStatuslineLspProgress', {
  event = 'LspProgress',
  desc = 'Update LSP progress in statusline',
  pattern = { 'begin', 'report', 'end' },
  command = function(args)
    if not (args.data and args.data.client_id) then return end

    local data = args.data
    local client = { name = vim.lsp.get_client_by_id(data.client_id).name }
    local message = require('ar.utils.lsp').process_progress_msg(client, {
      kind = data.params.value.kind,
      title = data.params.value.title,
      percentage = data.params.value.percentage,
      message = data.params.value.message,
    })

    if data.params.value.kind == 'end' then
      lsp_progress.message = nil
    else
      -- replace % with %% to avoid statusline issues
      lsp_progress.message = message:gsub('%%', '%%%%')
    end

    vim.defer_fn(function() vim.cmd.redrawstatus() end, 500)
  end,
})

--- @return string
local function lsp_status()
  if not rawget(vim, 'lsp') then return '' end

  if vim.o.columns < 120 then return '' end

  if not lsp_progress.message then return '' end

  return string.format('%%#StatusLineLspMessages#%s%%* ', lsp_progress.message)
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

--- @return string
local function git_branch_icon() return '%#StatusLineGitBranchIcon#%*' end

--- @return string
local function git_branch()
  local branch = vim.b.gitsigns_head
  if branch == '' or branch == nil then branch = stl.pretty_branch() end

  branch = ' ' .. git_branch_icon() .. ' ' .. branch
  return string.format('%%#StatusLineMedium#%s%%*', branch)
end

--- @return string
local function git_diff()
  local full = ''

  local added = git_diff_added()
  if added ~= '' then full = full .. added end

  local changed = git_diff_changed()
  if changed ~= '' then full = full .. changed end

  local removed = git_diff_removed()
  if removed ~= '' then full = full .. removed end

  return full .. ' '
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
      '%#StatusLineBar#▊%*',
      mode(),
      '%=',
      '%=',
      location(),
      '%#StatusLineBar#▊%*',
    })
  end

  if vim.bo.ft == '' then return table.concat({ '%#Normal#%' }) end

  if readeable_filetypes[vim.bo.filetype] or vim.o.modifiable == false then
    return table.concat({
      '%#StatusLineBar#▊%*',
      formatted_filetype('StatusLineMode'),
      '%=',
      '%=',
      location(),
      '%#StatusLineBar#▊%*',
    })
  end

  local statusline = {
    '%#StatusLineBar#▊%*',
    mode(),
    git_branch(),
    filename(),
    git_diff(),
    diagnostics_error(),
    diagnostics_warns(),
    diagnostics_info(),
    diagnostics_hint(),
    '%=',
    '%=',
    '%S ',
    lsp_status(),
    lsp_active(),
    python_env(),
    filetype(),
    lsp_clients(),
    location(),
    '%#StatusLineBar#▊%*',
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
