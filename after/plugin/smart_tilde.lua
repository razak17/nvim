local enabled = ar.config.plugin.custom.smart_tilde.enable

if not ar or ar.none or not enabled then return end

--------------------------------------------------------------------------------
-- Smart Tilde
--------------------------------------------------------------------------------
local toggleSigns = {
  ['|'] = '&',
  [','] = ';',
  ["'"] = '"',
  ['^'] = '$',
  ['/'] = '*',
  ['+'] = '-',
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
  ['<'] = '>',
  ['0'] = '1',
}

map({ 'n', 'x' }, '~', function()
  local col = vim.fn.col('.') -- fn.col correctly considers tab-indentation
  local charUnderCursor = vim.api.nvim_get_current_line():sub(col, col)
  local isLetter = charUnderCursor:find('^%a$')
  local function normal(cmd) vim.cmd.normal({ cmd, bang = true }) end
  if isLetter then
    normal('~')
    return
  end
  for left, right in pairs(toggleSigns) do
    if charUnderCursor == left then normal('r' .. right .. 'l') end
    if charUnderCursor == right then normal('r' .. left .. 'l') end
  end
end, { desc = 'smart tilde' })
