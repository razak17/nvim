local M = { records = {}, busy = false }
local cache = require('ar.core.pack.update-cache')
local restored = {}
local function changed()
  local status = package.loaded['ar.core.pack.update-status']
  if status and not M.worker then status.schedule() end
end
-- Cached results restore local state once. Checks fetch; apply() uses local refs and
-- revalidates the reviewed revision before handing checkout to vim.pack.

function M.eligible(entry)
  return entry ~= nil
    and entry.installed == true
    and entry.path ~= nil
    and not (entry.info and entry.info.dev)
end

local function matches(record, entry)
  return record
    and record.src == entry.src
    and record.name == entry.name
    and record.path == entry.path
    and record.constraint == entry.constraint
    and (
      record.inventory_revision == entry.revision or record.status == 'error'
    )
end

function M.cached(entry)
  if not M.eligible(entry) then return end
  local key = entry.id
    .. '\0'
    .. cache.key(entry)
    .. '\0'
    .. (entry.revision or '')
    .. '\0'
    .. (entry.constraint or '')
  if not M.records[entry.id] and not restored[key] then
    restored[key] = true
    M.records[entry.id] = cache.get(entry)
  end
  local record = M.records[entry.id]
  if matches(record, entry) then return vim.deepcopy(record) end
end

local function initial(entry)
  return {
    src = entry.src,
    name = entry.name,
    path = entry.path,
    inventory_revision = entry.revision,
    constraint = entry.constraint,
    checked_at = os.time(),
    status = 'checking',
  }
end

local function verify(entry, package)
  assert(
    package
      and package.spec
      and package.spec.name == entry.name
      and package.spec.src == entry.src
      and package.path == entry.path,
    'Package identity changed; refresh the inventory'
  )
  assert(vim.fn.isdirectory(package.path) == 1, 'Package directory is missing')
end

local function hash(value)
  return type(value) == 'string'
    and #value >= 7
    and value:match('^[%da-fA-F]+$') ~= nil
end

local function resolved(entry, package)
  verify(entry, package)
  assert(
    hash(package.rev) and hash(package.rev_to),
    'Could not resolve installed and target revisions; check remote access and the configured version'
  )
  local record = initial(entry)
  record.current, record.target = package.rev, package.rev_to
  record.status = package.rev == package.rev_to and 'current' or 'available'
  record.commits = {}
  if record.status == 'available' then
    local result = vim
      .system({
        'git',
        '-C',
        entry.path,
        'log',
        '--no-color',
        '--no-show-signature',
        '--format=%h %s',
        '--max-count=30',
        package.rev .. '..' .. package.rev_to,
        '--',
      }, { text = true })
      :wait(10000)
    assert(
      result.code == 0,
      'Could not read update commits: ' .. (result.stderr or '')
    )
    record.commits = vim.split(
      vim.trim(result.stdout or ''),
      '\n',
      { plain = true, trimempty = true }
    )
  end
  return record
end

local function failure(entry, err, operation)
  local record = initial(entry)
  record.status, record.error, record.operation =
    'error', tostring(err), operation
  M.records[entry.id] = record
  return record
end

function M.check(entries)
  assert(not M.busy, 'Another update operation is running')
  local eligible, names = {}, {}
  for _, entry in ipairs(entries) do
    if M.eligible(entry) then
      eligible[#eligible + 1], names[#names + 1] = entry, entry.name
    end
  end
  assert(#eligible > 0, 'No installed remote packages to check')
  M.busy = true
  changed()
  for _, entry in ipairs(eligible) do
    M.records[entry.id] = initial(entry)
  end
  local ok, packages =
    pcall(vim.pack.get, names, { info = true, offline = false })
  if ok and type(packages) ~= 'table' then
    ok, packages = false, 'Native package metadata is unavailable'
  end
  local by_name = {}
  if ok then
    for _, package in ipairs(packages) do
      if
        type(package) == 'table'
        and type(package.spec) == 'table'
        and package.spec.name
      then
        by_name[package.spec.name] = package
      end
    end
  end
  local result = { checked = #eligible, available = 0, failed = 0 }
  for _, entry in ipairs(eligible) do
    local valid, record
    if ok then
      valid, record = pcall(resolved, entry, by_name[entry.name])
    else
      valid, record = false, packages
    end
    if not valid then record = failure(entry, record, 'check') end
    M.records[entry.id] = record
    if record.status == 'available' then
      result.available = result.available + 1
    end
    if record.status == 'error' then result.failed = result.failed + 1 end
  end
  M.busy = false
  local completed = {}
  for _, entry in ipairs(eligible) do
    completed[entry.id] = M.records[entry.id]
  end
  if not M.worker then cache.save(completed) end
  changed()
  return result
end

--- Check in a separate Neovim process so native fetches and Git waits do not
--- block editing. The returned function cancels the check and restores its cache.
---@param entries table[]
---@param callback fun(result: table|nil, err?: string)
---@return fun() cancel
function M.check_async(entries, callback)
  assert(not M.busy, 'Another update operation is running')
  local eligible, previous, pending = {}, {}, {}
  for _, entry in ipairs(entries) do
    if M.eligible(entry) then
      eligible[#eligible + 1] = {
        id = entry.id,
        name = entry.name,
        src = entry.src,
        path = entry.path,
        revision = entry.revision,
        constraint = entry.constraint,
        installed = true,
      }
    end
  end
  assert(#eligible > 0, 'No installed remote packages to check')
  M.busy = true
  changed()
  for _, entry in ipairs(eligible) do
    previous[entry.id] = M.records[entry.id]
    pending[entry.id] = initial(entry)
    M.records[entry.id] = pending[entry.id]
  end
  local process, finished
  local function restore()
    for _, entry in ipairs(eligible) do
      if M.records[entry.id] == pending[entry.id] then
        M.records[entry.id] = previous[entry.id]
      end
    end
  end
  local function complete(output)
    if finished then return end
    finished = true
    local ok, payload = pcall(function()
      assert(output.code == 0, output.stderr or 'Update worker failed')
      local data = vim.json.decode(output.stdout or '')
      assert(not data.error, data.error)
      assert(
        type(data.summary) == 'table' and type(data.records) == 'table',
        'Invalid update worker response'
      )
      for _, entry in ipairs(eligible) do
        assert(
          matches(data.records[entry.id], entry),
          'Update worker returned a mismatched package'
        )
      end
      return data
    end)
    M.busy = false
    if not ok then
      restore()
      changed()
      callback(nil, tostring(payload))
      return
    end
    for _, entry in ipairs(eligible) do
      M.records[entry.id] = payload.records[entry.id]
    end
    cache.save(payload.records)
    changed()
    callback(payload.summary)
  end
  local worker = vim.fs.joinpath(
    vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)),
    '..',
    'check-worker.lua'
  )
  local ok, err = pcall(function()
    process = vim.system(
      { vim.v.progpath, '--clean', '--headless', '-i', 'NONE', '-l', worker },
      {
        text = true,
        stdin = vim.json.encode({
          entries = eligible,
          packlockfile = vim.fn.fnamemodify(
            vim.fn.expand(vim.o.packlockfile),
            ':p'
          ),
        }),
        timeout = 120000,
      },
      function(output)
        vim.schedule(function() complete(output) end)
      end
    )
  end)
  if not ok then
    finished = true
    M.busy = false
    restore()
    changed()
    error(err, 0)
  end
  return function()
    if finished then return end
    finished = true
    if process then process:kill(15) end
    M.busy = false
    restore()
    changed()
  end
end

function M.apply(entry)
  assert(not M.busy, 'Another update operation is running')
  assert(M.eligible(entry), 'Package is not eligible for native updates')
  local previous = M.cached(entry)
  assert(
    previous and previous.status == 'available',
    'Check this package for updates first'
  )
  local build = entry.info and entry.info.build
  assert(
    not build or (build.status ~= 'queued' and build.status ~= 'running'),
    'Wait for the package build to finish'
  )
  assert(entry.status ~= 'loading', 'Wait for plugin loading to finish')
  M.busy = true
  changed()
  local ok, result = pcall(function()
    local installed =
      vim.pack.get({ entry.name }, { info = true, offline = true })[1]
    local fresh = resolved(entry, installed)
    fresh.checked_at = previous.checked_at
    if fresh.current ~= previous.current or fresh.target ~= previous.target then
      M.records[entry.id] = fresh
      return {
        changed = true,
        message = 'Package revisions changed; review the refreshed details before updating',
      }
    end
    fresh.status = 'updating'
    M.records[entry.id] = fresh
    local builds = package.loaded['ar.core.pack.build']
    local before = builds and builds.jobs[entry.src]
    assert(
      not before
        or before.path ~= entry.path
        or (before.status ~= 'queued' and before.status ~= 'running'),
      'Wait for the package build to finish'
    )
    vim.pack.update(
      { entry.name },
      { force = true, offline = true, target = 'version' }
    )
    local after =
      vim.pack.get({ entry.name }, { info = true, offline = true })[1]
    verify(entry, after)
    assert(
      after.rev == fresh.target,
      'Package did not reach the checked target revision; inspect the native update log'
    )
    fresh.from = fresh.current
    fresh.status, fresh.current, fresh.inventory_revision =
      'updated', after.rev, after.rev
    fresh.needs_restart = installed.active == true
      or after.active == true
      or entry.status == 'loaded'
      or entry.status == 'failed'
    M.records[entry.id] = fresh
    builds = package.loaded['ar.core.pack.build']
    local job = builds and builds.jobs[entry.src]
    return {
      updated = true,
      needs_restart = fresh.needs_restart,
      job = job ~= before
          and job
          and job.path == entry.path
          and job.name == entry.name
          and job
        or nil,
      message = 'Updated '
        .. entry.name
        .. (
          fresh.needs_restart and '; restart Neovim to use the new code' or ''
        ),
    }
  end)
  M.busy = false
  if not ok then
    failure(entry, result, 'update')
    cache.save({ M.records[entry.id] })
    changed()
    error(result, 0)
  end
  cache.save({ M.records[entry.id] })
  changed()
  return result
end

return M
