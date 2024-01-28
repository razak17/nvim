local enabled = rvim.plugin.smart_tilde.enable

if not rvim or rvim.none or not enabled then return end

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
}

map({ 'n', 'x' }, '~', function()
  local col = vim.fn.col('.') -- fn.col correctly considers tab-indentation
  local charUnderCursor = vim.api.nvim_get_current_line():sub(col, col)
  local isLetter = charUnderCursor:find('^%a$')
  local function normal(cmd) vim.cmd.normal({ cmd, bang = true }) end
  if isLetter then
    normal('~h')
    return
  end
  for left, right in pairs(toggleSigns) do
    if charUnderCursor == left then normal('r' .. right) end
    if charUnderCursor == right then normal('r' .. left) end
  end
end, { desc = 'smart tilde' })
