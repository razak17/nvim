local M = {}

M.filters = {
  { id = 'all', label = 'All' },
  { id = 'loaded', label = 'Loaded' },
  { id = 'pending', label = 'Pending' },
  { id = 'failed', label = 'Failed' },
  { id = 'installed', label = 'Installed' },
  { id = 'unregistered', label = 'Unregistered' },
  { id = 'updates', label = 'Updates' },
}

local function source_name(src)
  local name = src:gsub('/+$', ''):match('([^/]+)$'):gsub('%.git$', '')
  return name
end

-- Merge by both source and native name. Local development checkouts remain
-- separate from installed remote copies, even when their source URLs match.
function M.collect(registrations, packages, inventory_available)
  local entries, by_source = {}, {}
  for _, info in ipairs(registrations) do
    local installed
    if inventory_available then installed = false end
    local entry = {
      id = 'registered:' .. info.src,
      name = info.name,
      src = info.src,
      status = info.status,
      registered = true,
      info = vim.deepcopy(info),
      installed = installed,
    }
    if info.dev and ar.pack.dev and ar.pack.dev.path then
      entry.path =
        vim.fs.joinpath(vim.fn.expand(ar.pack.dev.path), source_name(info.src))
      entry.installed = vim.fn.isdirectory(entry.path) == 1
    end
    entries[#entries + 1] = entry
    by_source[info.src] = entry
  end
  for _, package in ipairs(packages) do
    local spec = package.spec
    local entry = by_source[spec.src]
    if not entry or entry.name ~= spec.name or entry.info.dev then
      entry = {
        id = 'installed:' .. spec.name .. ':' .. spec.src,
        name = spec.name,
        src = spec.src,
        registered = false,
      }
      entries[#entries + 1] = entry
    end
    entry.path, entry.revision, entry.active =
      package.path, package.rev, package.active
    entry.constraint = spec.version and tostring(spec.version) or nil
    entry.installed = package.path ~= nil
      and vim.fn.isdirectory(package.path) == 1
    if not entry.registered then
      entry.status = not entry.installed and 'missing'
        or (entry.active and 'active' or 'installed')
    end
  end
  table.sort(entries, function(a, b)
    if a.name:lower() ~= b.name:lower() then
      return a.name:lower() < b.name:lower()
    end
    if a.name ~= b.name then return a.name < b.name end
    return a.id < b.id
  end)
  local updates = require('ar.core.pack.ui.updates')
  for _, entry in ipairs(entries) do
    entry.update = updates.cached(entry)
  end
  return entries
end

function M.snapshot()
  local errors = {}
  local ok, registrations = pcall(ar.pack.info)
  if not ok then
    errors[#errors + 1] = 'Could not read plugin registrations: '
      .. tostring(registrations)
    registrations = {}
  end
  local available, packages =
    pcall(vim.pack.get, nil, { info = false, offline = true })
  if not available then
    errors[#errors + 1] = 'Could not read installed packages: '
      .. tostring(packages)
    packages = {}
  end
  return {
    entries = M.collect(registrations, packages, available),
    errors = errors,
  }
end

function M.failed(entry)
  return entry.status == 'failed'
    or (entry.update ~= nil and entry.update.status == 'error')
    or (
      entry.info ~= nil
      and entry.info.build ~= nil
      and entry.info.build.status == 'failed'
    )
end

function M.filter(entries, query, filter)
  local selected = {}
  for _, entry in ipairs(entries) do
    local matches = filter == 'all'
      or (filter == 'loaded' and entry.status == 'loaded')
      or (filter == 'pending' and entry.registered and entry.status == 'registered')
      or (filter == 'failed' and M.failed(entry))
      or (filter == 'installed' and entry.installed == true)
      or (filter == 'unregistered' and not entry.registered)
      or (
        filter == 'updates'
        and entry.update ~= nil
        and entry.update.status == 'available'
      )
    local haystack = (entry.name .. ' ' .. entry.src):lower()
    for term in query:lower():gmatch('%S+') do
      if not haystack:find(term, 1, true) then
        matches = false
        break
      end
    end
    if matches then selected[#selected + 1] = entry end
  end
  return selected
end

local function flag(value)
  if value == nil then return 'unknown' end
  return value and 'yes' or 'no'
end

function M.details(entry, errors)
  if not entry then
    local lines = {
      'No matching packages.',
      '',
      'Change the search or filter to show packages.',
    }
    for _, err in ipairs(errors) do
      vim.list_extend(lines, { '', 'Inventory error:' })
      vim.list_extend(lines, vim.split(err, '\n', { plain = true }))
    end
    return lines
  end
  local lines = entry.info and require('ar.core.pack.info').details(entry.info)
    or {
      'Plugin: ' .. entry.name,
      'Source: ' .. entry.src,
      'State: ' .. entry.status,
    }
  local available = require('ar.core.pack.ui.actions').available(entry)
  local action_lines = { '', 'Actions:' }
  for _, name in ipairs({ 'check', 'update', 'load', 'rebuild', 'directory' }) do
    local action = available[name]
    action_lines[#action_lines + 1] = '  '
      .. action.key
      .. '  '
      .. action.label
      .. (action.reason and (': ' .. action.reason) or '')
  end
  for index = #action_lines, 1, -1 do
    table.insert(lines, 4, action_lines[index])
  end
  local update = entry.update
  local update_lines =
    { '', 'Updates: ' .. (update and update.status or 'not checked') }
  if update then
    if update.from then
      update_lines[#update_lines + 1] = 'Previous revision: ' .. update.from
    end
    if update.current then
      update_lines[#update_lines + 1] = 'Current revision: ' .. update.current
    end
    if update.target then
      update_lines[#update_lines + 1] = 'Target revision: ' .. update.target
    end
    update_lines[#update_lines + 1] = 'Last checked: '
      .. os.date('%Y-%m-%d %H:%M:%S', update.checked_at)
    if update.error then
      vim.list_extend(
        update_lines,
        vim.split(update.error, '\n', { plain = true })
      )
    end
    if update.commits and #update.commits > 0 then
      update_lines[#update_lines + 1] = update.status == 'updated'
          and 'Applied commits, up to 30:'
        or 'Commits toward target, up to 30:'
      for _, commit in ipairs(update.commits) do
        update_lines[#update_lines + 1] = '  ' .. commit
      end
    elseif update.status == 'available' then
      update_lines[#update_lines + 1] =
        'No new commits; the target may be an older or divergent revision.'
    end
    if update.needs_restart then
      update_lines[#update_lines + 1] =
        'Restart Neovim to use the updated code.'
    end
  else
    update_lines[#update_lines + 1] =
      'c checks this package; C checks installed remote packages.'
  end
  for index = #update_lines, 1, -1 do
    table.insert(lines, 4, update_lines[index])
  end
  vim.list_extend(lines, {
    '',
    'Registered in this config: ' .. flag(entry.registered),
    'On disk: ' .. flag(entry.installed),
    'Native active: ' .. flag(entry.active),
  })
  if entry.path then lines[#lines + 1] = 'Package directory: ' .. entry.path end
  if entry.revision then
    lines[#lines + 1] = 'Recorded revision: ' .. entry.revision
  end
  if not entry.registered then
    vim.list_extend(
      lines,
      { '', 'This package has no declaration in the current configuration.' }
    )
  end
  for _, err in ipairs(errors) do
    vim.list_extend(lines, { '', 'Inventory error:' })
    vim.list_extend(lines, vim.split(err, '\n', { plain = true }))
  end
  return lines
end

return M
