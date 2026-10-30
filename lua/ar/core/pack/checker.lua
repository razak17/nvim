local M = {}
local timer, group, generation, cancel = nil, nil, 0, nil

function M.stop()
  generation = generation + 1
  if timer then
    timer:stop()
    if not timer:is_closing() then timer:close() end
    timer = nil
  end
  if cancel then
    cancel()
    cancel = nil
  end
  if group then
    vim.api.nvim_del_augroup_by_id(group)
    group = nil
  end
end

--- Schedule checks for this Neovim session. Durations are in seconds.
--- No packages are installed, loaded, or updated by the checker.
---@param opts? {enabled?: boolean, interval?: number, delay?: number, notify?: boolean}
function M.setup(opts)
  opts = vim.tbl_extend('force', {
    enabled = false,
    interval = 3600,
    delay = 30,
    notify = true,
  }, opts or {})
  assert(type(opts.enabled) == 'boolean', 'checker.enabled must be boolean')
  assert(type(opts.notify) == 'boolean', 'checker.notify must be boolean')
  for _, key in ipairs({ 'interval', 'delay' }) do
    local value = opts[key]
    assert(
      type(value) == 'number'
        and value == value
        and value >= 0
        and value <= 2147483
        and (key ~= 'interval' or value > 0),
      'checker.' .. key .. ' must be a finite number of seconds'
    )
  end
  M.stop()
  if not opts.enabled then return end
  local token = generation
  local arm
  local function check()
    if token ~= generation then return end
    timer = nil
    local updates = require('ar.core.pack.ui.updates')
    if updates.busy then
      arm(opts.interval)
      return
    end
    local function complete(result, err)
      if token ~= generation then return end
      cancel = nil
      local ok = err == nil
      if not ok then result = err end
      -- Arm before user callbacks so a failing notification or hook cannot
      -- silently disable future checks. Reconfiguration can cancel this timer.
      arm(opts.interval)
      if ok and result then
        vim.api.nvim_exec_autocmds('User', {
          pattern = 'ArPackUpdatesChecked',
          data = result,
          modeline = false,
        })
      end
      if token ~= generation then return end
      if opts.notify then
        if not ok then
          vim.notify(
            'Package update check failed: ' .. tostring(result),
            vim.log.levels.WARN
          )
        elseif result and (result.available > 0 or result.failed > 0) then
          vim.notify(
            ('Package updates: %d available, %d failed. Open :ArPack and select the Updates filter.'):format(
              result.available,
              result.failed
            ),
            result.failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO
          )
        end
      end
    end
    local ok, err = pcall(function()
      local snapshot = require('ar.core.pack.ui.model').snapshot()
      assert(#snapshot.errors == 0, table.concat(snapshot.errors, '\n'))
      local entries = vim.tbl_filter(updates.eligible, snapshot.entries)
      if #entries == 0 then
        arm(opts.interval)
        return
      end
      cancel = updates.check_async(entries, complete)
    end)
    if not ok then complete(nil, tostring(err)) end
  end
  arm = function(seconds)
    timer = vim.defer_fn(check, math.max(1, math.floor(seconds * 1000)))
  end
  group = vim.api.nvim_create_augroup('ArPackChecker', { clear = true })
  vim.api.nvim_create_autocmd(
    'VimLeavePre',
    { group = group, callback = M.stop }
  )
  if vim.v.vim_did_enter == 1 then
    arm(opts.delay)
  else
    vim.api.nvim_create_autocmd('VimEnter', {
      group = group,
      once = true,
      callback = function() arm(opts.delay) end,
    })
  end
end

return M
