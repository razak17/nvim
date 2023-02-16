-- Inspiration
-- 1. vim-relativity
-- 2. numbers.vim - https://github.com/myusuf3/numbers.vim/blob/master/plugin/numbers.vim

if not rvim then return end

local api = vim.api
local M = {}

local number_filetype_exclusions = {
  'undotree',
  'dashboard',
  'log',
  'man',
  'netrw',
  'dap-repl',
  'markdown',
  'vimwiki',
  'vim-plug',
  'gitcommit',
  'toggleterm',
  'coc-explorer',
  'coc-list',
  'list',
  'NvimTree',
  'startify',
  'help',
  'orgagenda',
  'org',
  'lsputil_locations_list',
  'lsputil_symbols_list',
  'himalaya',
  'Trouble',
}

local number_buftype_exclusions = {
  'terminal',
  'help',
  'nofile',
  'acwrite',
  'quickfix',
}

local number_buftype_ignored = { 'quickfix' }

local function is_floating_win() return vim.fn.win_gettype() == 'popup' end

local is_enabled = true

---Determines whether or not a window should be ignored by this plugin
---@return boolean
local function is_ignored()
  return vim.tbl_contains(number_buftype_ignored, vim.bo.buftype) or is_floating_win()
end

-- block list certain plugins and buffer types
local function is_blocked()
  local win_type = vim.fn.win_gettype()

  if not api.nvim_buf_is_valid(0) and not api.nvim_buf_is_loaded(0) then return true end

  if win_type == 'command' or vim.wo.diff or vim.wo.previewwindow then return true end

  for _, ft in ipairs(number_filetype_exclusions) do
    if vim.bo.ft == ft or string.match(vim.bo.ft, ft) then return true end
  end

  if vim.tbl_contains(number_buftype_exclusions, vim.bo.buftype) then return true end
  return false
end

local function enable_relative_number()
  if is_ignored() or not is_enabled then return end
  if is_blocked() then
    vim.wo.number = false
    vim.wo.relativenumber = false
    return
  end
  vim.wo.number = true
  vim.wo.relativenumber = true
end

local function disable_relative_number()
  if is_ignored() then return end
  if is_blocked() then
    vim.wo.number = false
    vim.wo.relativenumber = false
    return
  end
  vim.wo.number = true
  vim.wo.relativenumber = false
end

rvim.command('ToggleRelativeNumber', function()
  is_enabled = not is_enabled
  if is_enabled then
    enable_relative_number()
    return
  end
  disable_relative_number()
end)
rvim.nnoremap('<leader>or', '<cmd>ToggleRelativeNumber<CR>', 'toggle relativenumber')

rvim.augroup('ToggleRelativeLineNumbers', {
  {
    event = { 'BufEnter', 'FileType', 'FocusGained', 'InsertLeave' },
    pattern = { '*' },
    command = function() enable_relative_number() end,
  },
  {
    event = { 'FocusLost', 'BufLeave', 'InsertEnter', 'TermOpen' },
    pattern = { '*' },
    command = function() disable_relative_number() end,
  },
})

return M
