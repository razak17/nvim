local M = {}
local state = { available = 0, failed = 0, busy = false }
local pending, generation = false, 0

--- A small copied snapshot; safe to call on every statusline redraw.
function M.get()
  local result = vim.tbl_extend('force', {}, state)
  local updates = package.loaded['ar.core.pack.ui.updates']
  result.busy = updates ~= nil and updates.busy or false
  return result
end

function M.refresh()
  local updates = require('ar.core.pack.ui.updates')
  local next_state = vim.tbl_extend('force', {}, state)
  next_state.busy = updates.busy
  -- Keep the last completed counts visible while a check is running.
  if not updates.busy then
    local ok, snapshot = pcall(
      function() return require('ar.core.pack.ui.model').snapshot() end
    )
    if ok and #snapshot.errors == 0 then
      next_state.available, next_state.failed, next_state.checked_at = 0, 0, nil
      for _, entry in ipairs(snapshot.entries) do
        local update = entry.update
        if update then
          if update.status == 'available' then
            next_state.available = next_state.available + 1
          end
          if update.status == 'error' then
            next_state.failed = next_state.failed + 1
          end
          next_state.checked_at =
            math.max(next_state.checked_at or 0, update.checked_at or 0)
        end
      end
    end
  end
  if vim.deep_equal(state, next_state) then return end
  state = next_state
  vim.api.nvim_exec_autocmds(
    'User',
    { pattern = 'ArPackUpdatesChanged', data = M.get(), modeline = false }
  )
  vim.cmd.redrawstatus()
end

function M.schedule()
  if pending then return end
  pending = true
  local token = generation
  vim.schedule(function()
    if token ~= generation then return end
    pending = false
    M.refresh()
  end)
end

function M.setup()
  generation, pending = generation + 1, false
  state = { available = 0, failed = 0, busy = false }
  local group =
    vim.api.nvim_create_augroup('ArPackUpdateStatus', { clear = true })
  vim.api.nvim_create_autocmd(
    'PackChanged',
    { group = group, callback = M.schedule }
  )
  if vim.v.vim_did_enter == 1 then
    M.schedule()
  else
    vim.api.nvim_create_autocmd(
      'VimEnter',
      { group = group, once = true, callback = M.schedule }
    )
  end
end

return M
