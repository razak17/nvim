local opt_l = vim.opt_local
local M = {}

local function mappings_notify(msg, type)
  vim.schedule(function() vim.notify(msg, type, { title = 'UI Toggles' }) end)
end

---@param opt string
function M.toggle_opt(opt)
  local prev = vim.api.nvim_get_option_value(opt, {})
  local value
  if type(prev) == 'boolean' then value = not prev end
  vim.wo[opt] = value
  mappings_notify(string.format('%s %s', opt, rvim.bool2str(vim.wo[opt])))
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
    string.format('conceal %s', rvim.bool2str(opt_l.conceallevel:get() == 2))
  )
end

--- Toggle conceal cursor=n|''
function M.toggle_conceal_cursor()
  vim.opt_local.concealcursor = rvim.falsy(opt_l.concealcursor:get()) and 'nv'
    or ''
  mappings_notify(
    string.format(
      'conceal cursor %s',
      rvim.bool2str(opt_l.concealcursor:get() == '')
    )
  )
end

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
