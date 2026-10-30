---@class PackBuildJob
---@field src string
---@field name string
---@field path string
---@field recipe string|string[]|function
---@field fingerprint string|function
---@field event AutocmdArgs
---@field timeout integer
---@field notify boolean
---@field status 'queued'|'running'|'success'|'skipped'|'failed'
---@field uses_slot? boolean
---@field in_callback? boolean
---@field process? vim.SystemObj
---@field revision? string
---@field stdout? string
---@field stderr? string
---@field code? integer
---@field error? string
---@field started_ns? number
---@field duration_ms? number

local M = {}
---@type table<string, PackBuildJob>
M.jobs = {}
local queue, running, active = {}, {}, 0
local pumping = false
local pump

local function revision(path)
  local ok, result = pcall(
    function()
      return vim
        .system({ 'git', '-C', path, 'rev-parse', 'HEAD' }, { text = true })
        :wait(5000)
    end
  )
  if ok and result.code == 0 then return vim.trim(result.stdout) end
end

local function cache_path(job)
  return vim.fs.joinpath(
    vim.fn.stdpath('state'),
    'ar-pack',
    'builds',
    vim.fn.sha256(job.src .. '\0' .. job.path) .. '.json'
  )
end

local function cached(job)
  if not job.revision or type(job.recipe) == 'function' then return false end
  local ok, entry = pcall(
    function()
      return vim.json.decode(
        table.concat(vim.fn.readfile(cache_path(job)), '\n')
      )
    end
  )
  return ok
    and type(entry) == 'table'
    and entry.revision == job.revision
    and entry.recipe == job.fingerprint
end

local function record_success(job)
  if
    not job.revision
    or type(job.recipe) == 'function'
    or revision(job.path) ~= job.revision
  then
    return
  end
  local path = cache_path(job)
  local temporary = path .. '.' .. vim.uv.os_getpid() .. '.' .. vim.uv.hrtime()
  local ok, err = pcall(function()
    vim.fn.mkdir(vim.fs.dirname(path), 'p')
    assert(vim.fn.writefile({
      vim.json.encode({
        revision = job.revision,
        recipe = job.fingerprint,
      }),
    }, temporary) == 0, 'Could not write build cache')
    assert(vim.uv.fs_rename(temporary, path))
  end)
  if not ok then
    vim.fn.delete(temporary)
    vim.notify(
      'Could not cache build for ' .. job.name .. ': ' .. tostring(err),
      vim.log.levels.WARN
    )
  end
end

local function finish(job, result, err)
  job.duration_ms = (vim.uv.hrtime() - job.started_ns) / 1e6
  job.code, job.stdout, job.stderr =
    result.code, result.stdout or '', result.stderr or ''
  job.status = not err and result.code == 0 and 'success' or 'failed'
  if job.status == 'success' then
    record_success(job)
  else
    local detail = err or vim.trim(job.stderr)
    if detail == '' then detail = vim.trim(job.stdout) end
    if detail == '' then detail = 'exit code ' .. tostring(job.code) end
    job.error = 'Build failed for ' .. job.name .. ': ' .. tostring(detail)
  end
  if job.uses_slot then
    running[job.src], active = nil, active - 1
  end
  if job.error and job.notify then
    vim.schedule(function() vim.notify(job.error, vim.log.levels.ERROR) end)
  end
  pump()
end

local function start(job)
  job.started_ns = vim.uv.hrtime()
  job.status, job.uses_slot, running[job.src], active =
    'running', true, true, active + 1
  -- A failed rebuild may have overwritten artifacts from the previous recipe.
  vim.fn.delete(cache_path(job))
  local command = type(job.recipe) == 'string' and { 'sh', '-c', job.recipe }
    or job.recipe
  local ok, process = pcall(vim.system, command, {
    cwd = job.path,
    text = true,
    timeout = job.timeout,
  }, function(result)
    vim.schedule(function() finish(job, result) end)
  end)
  if ok then
    job.process = process
  else
    finish(job, { code = -1 }, tostring(process))
  end
end

pump = function()
  if pumping then return end
  pumping = true
  local index = 1
  while active < 2 and index <= #queue do
    local job = queue[index]
    if running[job.src] then
      index = index + 1
    else
      table.remove(queue, index)
      start(job)
    end
  end
  pumping = false
end

local function await(job)
  assert(
    not job.in_callback,
    'Cannot wait for an active build callback: ' .. job.name
  )
  local function done()
    return job.status ~= 'queued' and job.status ~= 'running'
  end
  while not done() do
    local _, reason = vim.wait(1000, done, 10)
    if reason == -2 then error('Build wait interrupted for ' .. job.name, 0) end
  end
end

local function run(spec, event, loading, force)
  local path = assert(event.data.path, 'Build requires a plugin directory')
  local recipe = type(spec.build) == 'table' and vim.deepcopy(spec.build)
    or spec.build
  local rev = type(recipe) ~= 'function' and revision(path) or nil
  local fingerprint = type(recipe) == 'function' and recipe
    or vim.fn.sha256(vim.json.encode(recipe))
  local latest = M.jobs[spec.src]
  if
    latest
    and latest.path == path
    and latest.fingerprint == fingerprint
    and latest.revision == rev
    and (
      (loading and not force)
      or latest.status == 'queued'
      or latest.status == 'running'
    )
  then
    return latest
  end
  local job = {
    src = spec.src,
    name = event.data.spec.name,
    path = path,
    recipe = recipe,
    revision = rev,
    fingerprint = fingerprint,
    event = event,
    timeout = spec.build_timeout or 300000,
    status = 'queued',
    notify = event.data.kind == 'build' and event.data.background == true
      or (
        event.data.kind ~= 'build'
        and (spec.build_wait == false or event.data.kind == 'update')
      ),
  }
  M.jobs[spec.src] = job
  -- A fresh checkout has no generated artifacts, even if its revision is cached.
  if type(recipe) == 'function' then
    -- Callbacks can synchronously load plugins with their own builds. Keeping
    -- them outside the process queue allows those nested builds to start.
    job.status, job.in_callback = 'running', true
    job.started_ns = vim.uv.hrtime()
    local ok, err = xpcall(function() recipe(event) end, debug.traceback)
    job.in_callback = false
    finish(job, { code = ok and 0 or 1 }, not ok and err or nil)
  elseif not force and event.data.kind ~= 'install' and cached(job) then
    job.status = 'skipped'
  else
    queue[#queue + 1] = job
    pump()
  end
  return job
end

local function validate(spec)
  local recipe = spec.build
  local valid = type(recipe) == 'function'
    or (type(recipe) == 'string' and vim.trim(recipe) ~= '')
  if type(recipe) == 'table' and vim.islist(recipe) and #recipe > 0 then
    valid = true
    for _, argument in ipairs(recipe) do
      valid = valid and type(argument) == 'string'
    end
  end
  assert(
    valid,
    'build must be a callback, shell command or nonempty argument list'
  )
  assert(
    spec.build_wait == nil or type(spec.build_wait) == 'boolean',
    'build_wait must be boolean'
  )
  assert(
    spec.build_timeout == nil
      or (
        type(spec.build_timeout) == 'number'
        and spec.build_timeout > 0
        and spec.build_timeout % 1 == 0
      ),
    'build_timeout must be a positive integer'
  )
end

function M.register(spec)
  validate(spec)
  local recipe = spec.build
  local name = spec.name
    or spec.src:gsub('/+$', ''):match('([^/]+)$'):gsub('%.git$', '')
  local group = vim.api.nvim_create_augroup(name .. '_build', { clear = true })
  local id = vim.api.nvim_create_autocmd('PackChanged', {
    group = group,
    callback = function(event)
      local data = event.data
      if
        not data
        or not data.spec
        or data.spec.name ~= name
        or (data.kind ~= 'install' and data.kind ~= 'update')
      then
        return
      end
      local job = run(spec, event, false)
      if job.in_callback then return end
      if type(recipe) == 'function' or spec.build_wait ~= false then
        await(job)
      end
    end,
  })
  return function() pcall(vim.api.nvim_del_autocmd, id) end
end

-- Existing Lua callbacks retain their PackChanged-only lifecycle.
-- Commands also build on first load, covering installations with no build record.
function M.ensure(spec)
  if type(spec.build) == 'function' then return end
  local name = spec.name
    or spec.src:gsub('/+$', ''):match('([^/]+)$'):gsub('%.git$', '')
  local packs = vim.pack.get({ name }, { info = false })
  assert(
    packs[1] and packs[1].path,
    'Plugin directory not found for build: ' .. name
  )
  run(spec, {
    event = 'PackChanged',
    data = {
      kind = 'load',
      path = packs[1].path,
      spec = { name = name, src = spec.src },
    },
  }, true)
end

-- Manual builds bypass cached success. They do not rerun plugin setup.
function M.rebuild(spec, path, opts)
  opts = opts or {}
  validate(spec)
  assert(
    opts.wait == nil or type(opts.wait) == 'boolean',
    'wait must be boolean'
  )
  assert(vim.fn.isdirectory(path) == 1, 'Plugin directory not found: ' .. path)
  local name = spec.name
    or spec.src:gsub('/+$', ''):match('([^/]+)$'):gsub('%.git$', '')
  local job = run(spec, {
    event = 'User',
    match = 'ArPackBuild',
    buf = vim.api.nvim_get_current_buf(),
    data = {
      kind = 'build',
      path = path,
      spec = { src = spec.src, name = name, version = spec.version },
      active = ar.pack.loaded[spec.src] == true,
      background = opts.wait == false,
    },
  }, false, true)
  if opts.wait ~= false then M.wait(spec.src) end
  return job
end

function M.wait(src)
  local job
  repeat
    job = M.jobs[src]
    if not job then return end
    await(job)
  until M.jobs[src] == job
  if job.error then error(job.error, 0) end
end

return M
