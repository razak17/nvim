local M = {}

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
  rvim.mappings.notify(string.format('statusline %s', status))
end

--- Toggle conceal=2|0
local function toggle_conceal()
  vim.opt_local.conceallevel = vim.opt_local.conceallevel:get() == 0 and 2 or 0
  rvim.mappings.notify(
    string.format(
      'conceal %s',
      rvim.bool2str(vim.opt_local.conceallevel:get() == 2)
    )
  )
end

--- Toggle conceal cursor=n|''
local function toggle_conceal_cursor()
  vim.opt_local.concealcursor = vim.opt_local.concealcursor:get() == 'n' and ''
    or 'n'
  rvim.mappings.notify(
    string.format(
      'conceal cursor %s',
      rvim.bool2str(vim.opt_local.concealcursor:get() == '')
    )
  )
end
map('n', '<localleader>cl', toggle_conceal, { desc = 'toggle conceallevel' })
map(
  'n',
  '<localleader>cc',
  toggle_conceal_cursor,
  { desc = 'toggle concealcursor' }
)

function M.toggle_sunglasses()
  local success, _ = pcall(require, 'sunglasses')
  if not success then return end
  local is_shaded
  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    is_shaded = require('sunglasses.window').get(winnr):is_shaded()
    if is_shaded then
      vim.cmd('SunglassesDisable')
      return
    end
  end
  vim.cmd('SunglassesEnable')
  vim.cmd('SunglassesOff')
end

return M
