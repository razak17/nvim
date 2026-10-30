local M = {}

function M.available(entry)
  local result = {
    load = {
      label = 'Load',
      key = 'l',
      reason = 'Not registered in this configuration',
    },
    rebuild = { label = 'Rebuild', key = 'b', reason = 'No build configured' },
    directory = {
      label = 'Open directory',
      key = 'o',
      reason = 'Package directory is unavailable',
    },
    check = {
      label = 'Check updates',
      key = 'c',
      reason = 'Install this package before checking updates',
    },
    update = {
      label = 'Apply checked update',
      key = 'u',
      reason = 'Check this package for updates first',
    },
  }
  if not entry then
    for _, action in pairs(result) do
      action.reason = 'No package selected'
    end
    return result
  end
  if entry.registered then
    if entry.status == 'registered' then
      result.load.reason = nil
    elseif entry.status == 'loaded' then
      result.load.reason = 'Already loaded'
    elseif entry.status == 'failed' then
      result.load.reason = 'Restart Neovim to retry failed loading'
    else
      result.load.reason = 'Loading is already in progress'
    end
    if entry.info.has_build then
      local build = entry.info.build
      if not entry.path or not entry.installed then
        result.rebuild.reason = 'Package directory is unavailable'
      elseif
        build and (build.status == 'queued' or build.status == 'running')
      then
        result.rebuild.reason = 'A build is already in progress'
      elseif
        entry.info.build_type == 'function' and entry.status ~= 'loaded'
      then
        result.rebuild.reason =
          'Load the plugin before rebuilding its Lua callback'
      else
        result.rebuild.reason = nil
      end
    end
  end
  if entry.path and entry.installed then result.directory.reason = nil end
  local updates = require('ar.core.pack.ui.updates')
  if updates.eligible(entry) then
    result.check.reason = updates.busy and 'Another update operation is running'
      or nil
    local update = updates.cached(entry)
    if update and update.status == 'available' then
      local build = entry.info and entry.info.build
      result.update.reason = updates.busy
          and 'Another update operation is running'
        or (entry.status == 'loading' and 'Wait for plugin loading to finish')
        or (build and (build.status == 'queued' or build.status == 'running') and 'Wait for the package build to finish')
        or nil
    elseif
      update and (update.status == 'current' or update.status == 'updated')
    then
      result.update.reason = 'Already at the checked target revision'
    end
  elseif entry.info and entry.info.dev then
    result.check.reason, result.update.reason =
      'Development checkout; update it directly',
      'Development checkout; update it directly'
  end
  return result
end

function M.run(action, entry)
  local capability = M.available(entry)[action]
  assert(capability, 'Unknown package action: ' .. tostring(action))
  if capability.reason then return nil, capability.reason end
  if action == 'load' then
    ar.pack.load(entry.src)
    return { message = 'Loaded ' .. entry.name }
  elseif action == 'rebuild' then
    return {
      job = ar.pack.rebuild(entry.src, { wait = false }),
      message = 'Building ' .. entry.name,
      needs_restart = entry.status == 'failed',
    }
  elseif action == 'check' then
    local updates = require('ar.core.pack.ui.updates')
    local result = updates.check({ entry })
    local record = updates.cached(entry)
    if result.failed > 0 then error(record.error, 0) end
    return {
      message = result.available > 0
          and ('Update available for ' .. entry.name)
        or (entry.name .. ' is at its target revision'),
    }
  elseif action == 'update' then
    local result = require('ar.core.pack.ui.updates').apply(entry)
    result.context = 'update'
    return result
  end
  assert(
    vim.fn.isdirectory(entry.path) == 1,
    'Package directory is missing: ' .. entry.path
  )
  return { directory = entry.path }
end

function M.check_all(entries)
  local updates = require('ar.core.pack.ui.updates')
  local any = false
  for _, entry in ipairs(entries) do
    if updates.eligible(entry) then
      any = true
      break
    end
  end
  if not any then return nil, 'No installed remote packages to check' end
  local result = updates.check(entries)
  return {
    message = ('Checked %d packages: %d updates, %d failures'):format(
      result.checked,
      result.available,
      result.failed
    ),
    level = result.failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO,
  }
end

return M
