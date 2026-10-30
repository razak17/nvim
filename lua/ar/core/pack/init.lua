if ar.package_manager ~= 'vim.pack' then return end

local fn, api = vim.fn, vim.api
ar.augroup('PackInstall', {
  event = 'PackChanged',
  command = function(args)
    local data = args.data
    if data.kind ~= 'install' then return end
    vim.notify(
      'PackInstall: ' .. data.spec.name .. ' installed',
      vim.log.levels.INFO
    )
  end,
})

--------------------------------------------------------------------------------
--  vim.pack
--------------------------------------------------------------------------------

--- Load a plugin on command execution or completion, then use its real command.
---@param name string|string[]
---@param load? fun(reason?: table)
---@return fun() cleanup Removes only command stubs still owned by this call.
function ar.pack.cmd(name, load)
  if type(name) == 'table' then
    local cleanups = {}
    for _, command in ipairs(name) do
      cleanups[#cleanups + 1] = ar.pack.cmd(command, load)
    end
    return function()
      for _, cleanup in ipairs(cleanups) do
        cleanup()
      end
    end
  end
  local invoke
  local function cleanup()
    local command = api.nvim_get_commands({})[name]
    if command and command.callback == invoke then
      api.nvim_del_user_command(name)
    end
  end
  local function load_command(kind)
    cleanup()
    if load then load({ kind = kind, value = name }) end
    assert(
      fn.exists(':' .. name) == 2,
      'Plugin did not define command: ' .. name
    )
  end
  invoke = function(info)
    load_command('command')
    local range = ''
    if info.range == 1 then
      range = tostring(info.line2)
    elseif info.range == 2 then
      range = info.line1 .. ',' .. info.line2
    end
    -- Parse after loading so nargs, count, and escaping follow the real command.
    local command = api.nvim_parse_cmd(
      range .. name .. (info.bang and '!' or '') .. ' ' .. info.args,
      {}
    )
    command.mods = info.smods
    -- Let the command apply its default count without creating an explicit range.
    if info.range == 0 then command.count = nil end
    api.nvim_cmd(command, {})
    if command.nextcmd ~= '' then vim.cmd(command.nextcmd) end
  end
  api.nvim_create_user_command(name, invoke, {
    nargs = '*',
    bang = true,
    range = true,
    -- Counts may exceed the number of lines; the real command validates addresses.
    addr = 'other',
    complete = function(_, cmdline, cursorpos)
      load_command('completion')
      return fn.getcompletion(cmdline:sub(1, cursorpos), 'cmdline')
    end,
  })
  return cleanup
end

---@alias PackDependency PackSpec

---@class PackKey
---@field [1] string
---@field [2] string|fun()
---@field mode? string|string[]
---@field desc? string
---@field noremap? boolean
---@field silent? boolean

---@class PackSpec
---@field src string
---@field load? boolean Forwarded to native package loading; false skips plugin scripts.
---@field name? string
---@field version? string|vim.VersionRange
---@field dev? boolean Load from ar.pack.dev.path instead of installing from src.
---@field lazy? boolean Defaults to ar.pack.defaults.lazy.
---@field init? fun():nil
---@field build? string|string[]|fun(args: AutocmdArgs):nil
---@field build_wait? boolean Wait for command builds before setup; defaults to true.
---@field build_timeout? integer Command timeout in milliseconds; defaults to 300000.
---@field cond? boolean|fun():boolean
---@field cmd? string|string[]
---@field ft? string|string[]
---@field setup? fun():nil
---@field dependencies? PackDependency[]
---@field keys? PackKey[]|fun(load: fun()):PackKey[]|nil
---@field event? string|string[]

local dev_package_root

---@param spec PackSpec|PackDependency
local function load_dev(spec)
  local name = spec.src:gsub('/+$', ''):match('([^/]+)$')
  assert(name, 'Invalid dev plugin source: ' .. spec.src)
  name = name:gsub('%.git$', '')
  local path = vim.fs.joinpath(vim.fn.expand(ar.pack.dev.path), name)
  local resolved = vim.uv.fs_realpath(path)
  if not resolved or vim.fn.isdirectory(resolved) ~= 1 then
    error('Dev plugin directory not found: ' .. path)
  end

  if not dev_package_root then
    dev_package_root = vim.fn.tempname()
    vim.fn.mkdir(
      vim.fs.joinpath(dev_package_root, 'pack', 'ar-dev', 'opt'),
      'p'
    )
    vim.opt.packpath:prepend(dev_package_root)
  end
  -- A unique package name avoids matching an installed remote package.
  local package_name = 'ar-dev-' .. vim.fn.sha256(resolved)
  local link =
    vim.fs.joinpath(dev_package_root, 'pack', 'ar-dev', 'opt', package_name)
  if not vim.uv.fs_lstat(link) then
    local ok, err = vim.uv.fs_symlink(resolved, link, { dir = true })
    assert(ok, err)
  end
  vim.cmd.packadd({ package_name, bang = spec.load == false })
end

---@param spec PackSpec|PackDependency
---@return boolean
local function check_condition(spec)
  if type(spec.cond) == 'function' then spec.cond = spec.cond() end
  if spec.cond == nil then spec.cond = true end
  return spec.cond
end

local pack_states, loading_path = {}, {}

local function note_trigger(state, kind, value)
  state.triggers = state.triggers
    or { commands = {}, events = {}, filetypes = {}, keys = {} }
  local values = state.triggers[kind]
  if not vim.tbl_contains(values, value) then values[#values + 1] = value end
end

---@param spec PackSpec|PackDependency
---@param reason? table
local function load_spec(spec, reason)
  if ar.pack.loaded[spec.src] then return end
  local state = pack_states[spec.src]
  if state and state.status == 'failed' then error(state.error, 0) end
  if state and state.status == 'loading' then
    error(
      'Circular plugin load: '
        .. table.concat(loading_path, ' -> ')
        .. ' -> '
        .. spec.src,
      0
    )
  end
  if not check_condition(spec) then return end
  spec = state and state.spec or spec
  state = state or {}
  pack_states[spec.src] = state
  local started = vim.uv.hrtime()
  state.started_ns, state.reason = started, reason or { kind = 'manual' }
  state.status = 'loading'
  loading_path[#loading_path + 1] = spec.src
  local ok, err = xpcall(function()
    local cleanups = state.cleanups or {}
    state.cleanups = nil
    for _, cleanup in ipairs(cleanups) do
      cleanup()
    end
    for _, dep in ipairs(spec.dependencies or {}) do
      load_spec(dep, { kind = 'dependency', parent = spec.src })
    end
    if spec.dev then
      load_dev(spec)
    else
      vim.pack.add(
        { { src = spec.src, name = spec.name, version = spec.version } },
        { confirm = false, load = spec.load }
      )
    end
    if spec.build and not spec.dev then
      local builds = require('ar.core.pack.build')
      builds.ensure(spec)
      if type(spec.build) == 'function' or spec.build_wait ~= false then
        builds.wait(spec.src)
      end
    end
    if spec.setup then spec.setup() end
    for _, restore in ipairs(state.keymaps or {}) do
      restore()
    end
  end, debug.traceback)
  state.keymaps = nil
  state.load_ms = (vim.uv.hrtime() - started) / 1e6
  loading_path[#loading_path] = nil
  if not ok then
    state.status, state.error = 'failed', err
    error(err, 0)
  end
  state.status = 'loaded'
  ar.pack.loaded[spec.src] = true
end

local function event_groups(event)
  local groups = {}
  for _, autocmd in ipairs(api.nvim_get_autocmds({ event = event })) do
    if autocmd.group then groups[autocmd.group] = true end
  end
  return groups
end

local function replay_event(event, existing_groups)
  if
    not api.nvim_buf_is_valid(event.buf)
    or not api.nvim_buf_is_loaded(event.buf)
  then
    return
  end
  local groups, seen = {}, {}
  for _, autocmd in ipairs(api.nvim_get_autocmds({ event = event.event })) do
    local group = autocmd.group
    if group and not existing_groups[group] and not seen[group] then
      groups[#groups + 1], seen[group] = group, true
    end
  end
  for _, group in ipairs(groups) do
    if
      not api.nvim_buf_is_valid(event.buf)
      or not api.nvim_buf_is_loaded(event.buf)
    then
      return
    end
    -- An earlier handler may have deleted the next group.
    local ok, handlers =
      pcall(api.nvim_get_autocmds, { event = event.event, group = group })
    if ok and #handlers > 0 then
      local opts = { group = group, data = event.data, modeline = false }
      local buffer_match = event.match == api.nvim_buf_get_name(event.buf)
        or (event.event == 'FileType' and event.match == vim.bo[event.buf].filetype)
        or (event.event == 'Syntax' and event.match == vim.bo[event.buf].syntax)
      if buffer_match then
        opts.buffer = event.buf
        api.nvim_exec_autocmds(event.event, opts)
      else
        -- User, CmdlineEnter, ModeChanged, etc. match something other than a file.
        opts.pattern = event.match
        local function execute() api.nvim_exec_autocmds(event.event, opts) end
        if api.nvim_get_current_buf() == event.buf then
          execute()
        else
          api.nvim_buf_call(event.buf, execute)
        end
      end
    end
  end
end

---@param load fun(reason?: table)
---@return fun() cancel
local function on_very_lazy(load)
  local active, autocmd = true, nil
  local function schedule_load()
    vim.schedule(function()
      if not active or vim.v.exiting ~= vim.NIL then return end
      load({ kind = 'deferred', value = 'VeryLazy' })
    end)
  end

  if vim.v.vim_did_enter == 1 then
    schedule_load()
  else
    autocmd = vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = schedule_load,
    })
  end
  return function()
    active = false
    if autocmd then pcall(api.nvim_del_autocmd, autocmd) end
  end
end

local function global_keymap(mode, lhs)
  local expand = api.nvim_replace_termcodes
  local target = expand(lhs, true, true, true)
  for _, mapping in ipairs(api.nvim_get_keymap(mode)) do
    if expand(mapping.lhs, true, true, true) == target then return mapping end
  end
end

local function register_key(state, key, load, declaration)
  local lhs, rhs = key[1], key[2]
  local modes = key.mode or 'n'
  if type(modes) == 'string' then modes = { modes } end
  -- Expand combined modes so a replacement in one mode preserves the others.
  local aliases = {
    v = { 'x', 's' },
    [''] = { 'n', 'x', 's', 'o' },
    ['!'] = { 'i', 'c' },
  }
  local expanded = {}
  for _, mode in ipairs(modes) do
    for _, actual in ipairs(aliases[mode] or { mode }) do
      expanded[actual] = true
    end
  end
  state.keybindings = state.keybindings or {}
  local normalized = api.nvim_replace_termcodes(lhs, true, true, true)
  for mode in pairs(expanded) do
    local id = mode .. '\0' .. normalized
    local previous = state.keybindings[id]
    if
      previous
      and state.declarations[previous] > state.declarations[declaration]
    then
      expanded[mode] = nil
    else
      state.keybindings[id] = declaration
    end
  end
  for mode in pairs(expanded) do
    note_trigger(state, 'keys', mode .. ' ' .. lhs)
  end
  local opts = {
    desc = key.desc,
    remap = key.noremap == false,
    silent = key.silent ~= false,
  }
  -- A keys callback can load synchronously before returning its declarations.
  if state.status == 'loaded' then
    for mode in pairs(expanded) do
      if rhs ~= nil and not global_keymap(mode, lhs) then
        vim.keymap.set(mode, lhs, rhs, opts)
      end
    end
    return
  end
  local replay = api.nvim_replace_termcodes(lhs, true, false, true)
  local function trigger()
    load({ kind = 'key', value = lhs, mode = fn.mode(1) })
    api.nvim_feedkeys(replay, 'mi', false)
  end
  for mode in pairs(expanded) do
    local owned = false
    vim.keymap.set(mode, lhs, trigger, opts)
    state.cleanups[#state.cleanups + 1] = function()
      local mapping = global_keymap(mode, lhs)
      owned = mapping ~= nil and mapping.callback == trigger
      if owned then vim.keymap.del(mode, lhs) end
    end
    state.keymaps[#state.keymaps + 1] = function()
      if owned and rhs ~= nil and not global_keymap(mode, lhs) then
        vim.keymap.set(mode, lhs, rhs, opts)
      end
    end
  end
end

---@param spec PackSpec
local function register_triggers(spec, state)
  local function load(event)
    local reason = { kind = 'manual' }
    if type(event) == 'table' then
      if event.event then
        reason = {
          kind = 'event',
          value = event.event,
          buf = event.buf,
          match = event.match,
        }
      elseif event.kind then
        reason = { kind = event.kind, value = event.value, mode = event.mode }
      end
    end
    if
      type(event) ~= 'table'
      or not event.event
      or ar.pack.loaded[spec.src]
    then
      load_spec(spec, reason)
      return
    end
    local existing_groups = event_groups(event.event)
    load_spec(spec, reason)
    if ar.pack.loaded[spec.src] then replay_event(event, existing_groups) end
  end
  for field, kind in pairs({
    cmd = 'commands',
    event = 'events',
    ft = 'filetypes',
  }) do
    local values = spec[field]
    if type(values) == 'string' then values = { values } end
    for _, value in ipairs(values or {}) do
      note_trigger(state, kind, value)
    end
  end
  if spec.cmd and not ar.pack.loaded[spec.src] then
    state.cleanups[#state.cleanups + 1] = ar.pack.cmd(spec.cmd, load)
  end
  local function register_event(event, opts)
    local id = api.nvim_create_autocmd(event, opts)
    state.cleanups[#state.cleanups + 1] = function()
      pcall(api.nvim_del_autocmd, id)
    end
  end
  if spec.event and not ar.pack.loaded[spec.src] then
    local events = type(spec.event) == 'string' and { spec.event } or spec.event
    for _, event in ipairs(events) do
      if event == 'VeryLazy' then
        state.cleanups[#state.cleanups + 1] = on_very_lazy(load)
      else
        register_event(event, {
          once = true,
          callback = load,
        })
      end
    end
  end
  if spec.ft and not ar.pack.loaded[spec.src] then
    register_event('FileType', {
      pattern = spec.ft,
      once = true,
      callback = load,
    })
  end
  if spec.keys then
    local keys = spec.keys
    if type(keys) == 'function' then
      state.keys_callback = true
      keys = keys(load)
    end
    if state.status == 'failed' then load() end
    if type(keys) ~= 'table' then return end
    for _, key in ipairs(keys) do
      register_key(state, key, load, spec)
    end
  end
end

local function collect_spec(spec, dependency, order, seen)
  if ar.pack.loaded[spec.src] then return end
  local state = pack_states[spec.src]
  if state and (state.status == 'loading' or state.status == 'failed') then
    load_spec(spec)
    return
  end
  if not check_condition(spec) then return end
  if not state then
    state = {
      status = 'registered',
      spec = { src = spec.src, dependencies = {} },
      declarations = {},
      priorities = {},
      dependencies = {},
      pending = {},
      default_lazy = true,
    }
    pack_states[spec.src] = state
  end
  if not seen[state] then
    order[#order + 1], seen[state] = state, true
  end
  if not dependency and not state.standalone then
    state.standalone, state.default_lazy = true, ar.pack.defaults.lazy
  end
  local priority = dependency and 1 or 2
  local previous = state.declarations[spec] or 0
  if previous >= priority or state.preparing then return end
  state.declarations[spec] = priority
  if previous == 0 then state.pending[#state.pending + 1] = spec end
  for field, value in pairs(spec) do
    if
      field ~= 'dependencies' and priority >= (state.priorities[field] or 0)
    then
      state.spec[field], state.priorities[field] = value, priority
    end
  end
  for _, dep in ipairs(spec.dependencies or {}) do
    if check_condition(dep) then
      if not state.dependencies[dep.src] then
        state.dependencies[dep.src] = true
        state.spec.dependencies[#state.spec.dependencies + 1] = dep
      end
      collect_spec(dep, true, order, seen)
    end
  end
end

local function prepare_spec(state)
  local spec = state.spec
  if ar.pack.loaded[spec.src] or state.preparing then return end
  if state.status == 'loading' or state.status == 'failed' then
    load_spec(spec)
    return
  end
  state.preparing = true
  state.cleanups, state.keymaps = state.cleanups or {}, state.keymaps or {}
  local ok, err = xpcall(function()
    for _, dep in ipairs(spec.dependencies) do
      if check_condition(dep) and pack_states[dep.src] then
        prepare_spec(pack_states[dep.src])
      end
    end
    if spec.init and not state.initialized then
      state.initialized = true
      spec.init()
    end
    local changed_build = state.build ~= spec.build
      or state.build_name ~= spec.name
    if
      state.build_cleanup and (changed_build or spec.dev or not spec.build)
    then
      state.build_cleanup()
      state.build_cleanup = nil
    end
    if spec.build and not spec.dev and not state.build_cleanup then
      state.build_cleanup = require('ar.core.pack.build').register(spec)
      state.build, state.build_name = spec.build, spec.name
    end
    local pending = state.pending
    state.pending = {}
    for _, declaration in ipairs(pending) do
      register_triggers(declaration, state)
    end
  end, debug.traceback)
  state.preparing = nil
  if not ok then
    for _, cleanup in ipairs(state.cleanups or {}) do
      pcall(cleanup)
    end
    state.cleanups, state.keymaps = nil, nil
    state.status, state.error = 'failed', err
    state.reason = state.reason or { kind = 'registration' }
    error(err, 0)
  end
end

local function registered_state(name)
  local state = pack_states[name]
  if not state then
    for src, candidate in pairs(pack_states) do
      local package_name = candidate.spec.name
        or src:gsub('/+$', ''):match('([^/]+)$'):gsub('%.git$', '')
      if package_name == name then
        assert(
          not state,
          'Ambiguous plugin name: ' .. name .. '; use its source URL'
        )
        state = candidate
      end
    end
  end
  assert(state, 'Unknown registered plugin: ' .. name)
  return state
end

--- Load a registered source URL or an unambiguous native package name.
---@param name string
---@return boolean loaded True only when this call loads the plugin.
function ar.pack.load(name)
  local state = registered_state(name)
  if ar.pack.loaded[state.spec.src] then return false end
  prepare_spec(state)
  load_spec(state.spec, { kind = 'manual', value = name })
  return ar.pack.loaded[state.spec.src] == true
end

--- Force a registered plugin's build without repeating its setup.
--- Lua callbacks require a loaded plugin and receive data.kind = 'build'.
---@param name string Source URL or unambiguous native package name.
---@param opts? {wait?: boolean} Defaults to waiting; false returns a background job.
---@return PackBuildJob
function ar.pack.rebuild(name, opts)
  local state = registered_state(name)
  local spec = state.spec
  assert(spec.build, 'No build configured for ' .. name)
  assert(
    type(spec.build) ~= 'function' or ar.pack.loaded[spec.src],
    'Load the plugin before rebuilding its Lua callback'
  )
  local path
  if spec.dev then
    local repository =
      spec.src:gsub('/+$', ''):match('([^/]+)$'):gsub('%.git$', '')
    path = vim.fs.joinpath(vim.fn.expand(ar.pack.dev.path), repository)
  else
    local package_name = spec.name
      or spec.src:gsub('/+$', ''):match('([^/]+)$'):gsub('%.git$', '')
    local package =
      vim.pack.get({ package_name }, { info = false, offline = true })[1]
    assert(
      package and package.spec and package.spec.src == spec.src,
      'Installed package source does not match ' .. spec.src
    )
    path = package.path
  end
  assert(path, 'Plugin directory is unavailable for ' .. name)
  return require('ar.core.pack.build').rebuild(spec, path, opts)
end

---@class PackInfo
---@field src string
---@field name string
---@field status string
---@field lazy boolean
---@field dev boolean
---@field dependencies string[]
---@field triggers table
---@field keys_callback boolean
---@field reason? table
---@field load_ms? number Inclusive of dependencies and waited builds.
---@field error? string
---@field build? table
---@field has_build boolean
---@field build_type? string

local function pack_info(state)
  local spec = state.spec
  local lazy = spec.lazy
  if lazy == nil then lazy = state.default_lazy end
  local info = {
    src = spec.src,
    name = spec.name
      or spec.src:gsub('/+$', ''):match('([^/]+)$'):gsub('%.git$', ''),
    status = state.status,
    lazy = lazy == true,
    dev = spec.dev == true,
    has_build = spec.build ~= nil and spec.build ~= false,
    build_type = spec.build and type(spec.build) or nil,
    dependencies = {},
    triggers = vim.deepcopy(
      state.triggers
        or { commands = {}, events = {}, filetypes = {}, keys = {} }
    ),
    keys_callback = state.keys_callback == true,
    reason = state.reason and vim.deepcopy(state.reason) or nil,
    load_ms = state.load_ms,
    error = state.error ~= nil and tostring(state.error) or nil,
  }
  if state.status == 'loading' and state.started_ns then
    info.load_ms = (vim.uv.hrtime() - state.started_ns) / 1e6
  end
  for _, dep in ipairs(spec.dependencies) do
    info.dependencies[#info.dependencies + 1] = dep.src
  end
  local builds = package.loaded['ar.core.pack.build']
  local job = builds and builds.jobs[spec.src]
  if job then
    info.build = {}
    for _, field in ipairs({
      'status',
      'path',
      'revision',
      'duration_ms',
      'code',
      'stdout',
      'stderr',
      'error',
    }) do
      info.build[field] = job[field]
    end
    info.build.command = type(job.recipe) == 'function' and 'Lua callback'
      or vim.deepcopy(job.recipe)
  end
  return info
end

--- Return copied diagnostics without loading plugins or querying package updates.
---@param name? string Source URL or unambiguous native package name.
---@return PackInfo|PackInfo[]
function ar.pack.info(name)
  if name then return pack_info(registered_state(name)) end
  local info = {}
  for _, state in pairs(pack_states) do
    info[#info + 1] = pack_info(state)
  end
  table.sort(info, function(a, b)
    if a.name == b.name then return a.src < b.src end
    return a.name < b.name
  end)
  return info
end

--- Counts describe wrapper registrations, not every plugin installed on disk.
---@return table
function ar.pack.stats()
  local stats = {
    count = 0,
    registered = 0,
    loading = 0,
    loaded = 0,
    failed = 0,
    builds = {},
  }
  local builds = package.loaded['ar.core.pack.build']
  for src, state in pairs(pack_states) do
    stats.count = stats.count + 1
    stats[state.status] = stats[state.status] + 1
    local job = builds and builds.jobs[src]
    if job then
      local status = job.status
      stats.builds[status] = (stats.builds[status] or 0) + 1
    end
  end
  return stats
end

--- Browse registered and installed packages using local metadata.
--- l loads a registered plugin, b forces its configured build, and o opens its
--- directory in a split. Manual builds preserve cached loader failures.
--- c checks the selected package, C checks installed remote packages, and u
--- applies its displayed target with native version constraints and build hooks.
--- Browsing and r refresh stay offline. Checks can also run on a configured timer.
---@param opts? {query?: string, filter?: string}
function ar.pack.open(opts) return require('ar.core.pack.ui').open(opts) end

--- Configure periodic update checks for this session. Durations are in seconds.
---@param opts? {enabled?: boolean, interval?: number, delay?: number, notify?: boolean}
function ar.pack.setup_checker(opts)
  require('ar.core.pack.checker').setup(opts or ar.pack.checker)
end

api.nvim_create_user_command(
  'ArPack',
  function(args) ar.pack.open(args.args ~= '' and { query = args.args } or nil) end,
  { nargs = '*', desc = 'Browse packages, dependencies and build output' }
)

api.nvim_create_user_command('ArPackInfo', function(args)
  local name = args.args ~= '' and args.args or nil
  require('ar.core.pack.info').open(function() return ar.pack.info(name) end)
end, {
  nargs = '?',
  desc = 'Inspect plugin loading, dependencies and build results',
  complete = function(lead)
    local counts, candidates = {}, {}
    for _, info in ipairs(ar.pack.info()) do
      counts[info.name] = (counts[info.name] or 0) + 1
      candidates[#candidates + 1] = info.src
    end
    for name, count in pairs(counts) do
      if count == 1 then candidates[#candidates + 1] = name end
    end
    table.sort(candidates)
    return vim.tbl_filter(
      function(candidate) return vim.startswith(candidate, lead) end,
      candidates
    )
  end,
})

--- Register one plugin spec or a list of specs with vim.pack. The whole batch
--- and its dependency specs register before eager loading; an empty list does
--- nothing. Supports command, filetype, key, or event loading. Standalone specs
--- default to ar.pack.defaults.lazy; dependency-only specs default to lazy.
--- Set lazy = false to load after registration, even with triggers. With
--- lazy = true, loading requires a trigger or use as a dependency; no triggers
--- means no automatic loading. ar.pack.load(src_or_name) explicitly loads a
--- registered source URL or unambiguous package name, returning false if loaded.
--- ar.pack.info(name) returns a copied plugin snapshot; no argument lists all
--- registrations. ar.pack.stats() returns state and build counts. :ArPackInfo
--- [name] opens a scratch report, with r to refresh and q to close. Load timings
--- include dependencies and waited builds; their sum is not a startup duration.
--- Any supplied trigger can load it. Filetype triggers handle future FileType events.
--- Owned command, key, event, and filetype triggers are removed before loading
--- dependencies or setup, including when loading later fails. Successful loading
--- installs declared key actions where setup has not supplied a mapping. Later
--- command and key replacements are preserved. Pending VeryLazy work is cancelled.
--- Triggers created manually inside keys(load) remain the caller's responsibility.
--- load = false uses native :packadd! behavior: add runtime paths without sourcing
--- plugin scripts immediately. setup still runs; lazy controls registration timing.
---
--- event accepts an autocmd event name or list, such as 'InsertEnter' or
--- { 'BufReadPost', 'BufNewFile' }. Only future events trigger loading; the event
--- is replayed after successful loading for augroups with no prior handlers for
--- that event, including handlers added by dependencies during loading. Existing
--- groups for that event and ungrouped handlers are skipped to avoid rerunning
--- unrelated handlers. Replay preserves the triggering buffer, match and data,
--- uses native pattern matching and once behavior, and skips deleted buffers.
--- Command, key and VeryLazy loading do not synthesize past events.
--- 'VeryLazy' schedules loading after VimEnter, or on the next scheduled callback
--- if startup has finished. It can appear in event lists and does not emit a
--- global User VeryLazy event. Scheduled loading is skipped while exiting.
---
--- keys entries contain a lhs and a string or function action, with optional
--- mode and desc fields. The default mode is normal. On first use, the plugin
--- loads and the pressed key is replayed through the resulting mapping.
--- Counts and registers on the first press are not explicitly preserved.
---
--- init runs once per source during registration, before its triggers or loading.
--- Dependency initialization precedes parent initialization. Use init for globals
--- or other configuration that must precede plugin loading. cond = false skips
--- registration, initialization, build hooks, and that declaration's dependencies.
---
--- Declarations share a source registry. Standalone fields take precedence over
--- inline dependency fields; later declarations at the same level win. Dependency
--- lists combine in declaration order and triggers accumulate. Conflicting key
--- actions prefer standalone declarations, then the latest declaration. Reusing
--- a spec table does not repeat its registration callbacks. Already loaded
--- sources ignore later declarations and are never reconfigured automatically.
---
--- Dependencies load before the plugin, and setup runs after vim.pack.add().
--- Each source URL loads and configures once through this wrapper, so use the
--- same full URL in standalone entries and dependencies. Recursive loads are
--- rejected; cycles report the active source URL path. A failed
--- load retains its error and is not retried in the same session, since plugin
--- scripts or setup may have already run partially. Only successful setup marks
--- the source as loaded in ar.pack.loaded. Installation does not
--- prompt for confirmation. Set cond = false to skip loading and trigger creation.
--- cond also accepts a function returning a boolean. Its result is cached on the
--- declaration at registration, including dependency declarations.
---
--- dev = true loads ar.pack.dev.path/<repository-name> through a temporary native
--- package symlink. The default dev directory is ~/projects. A trailing .git is
--- removed from the repository name. Missing checkouts raise an error; there is
--- no remote fallback. Dev plugins skip PackChanged build hooks and keep src as
--- their loaded-cache key. Dependencies can also set dev = true.
--- name and version are forwarded to vim.pack for remote plugins and dependencies.
--- Build hooks match the explicit name when supplied.
---
--- build accepts a shell command string, an argument list, or a Lua callback.
--- Commands run in the plugin directory through vim.system, with at most two
--- command builds running concurrently and one per source. build_wait defaults
--- to true so builds finish before setup; false permits background command
--- builds. build_timeout sets the command timeout in milliseconds, default 300000.
--- Failures capture stdout, stderr, and exit code; waited failures prevent setup.
--- require('ar.core.pack.build').jobs[src] exposes the latest build result.
---
--- Successful command builds are cached by revision and command under the state
--- directory's ar-pack/builds folder. Commands also run on first load if no build
--- record exists. Fresh installations always rebuild; failed attempts invalidate
--- earlier records. Lua callbacks retain their original PackChanged arguments,
--- run synchronously on each install or update, and manage any work they schedule
--- themselves. Callback results are not cached across revisions or sessions.
--- Dependency entries support the full spec, including init, build and triggers.
---
--- e.g.
--- ```lua
---   ar.pack.add({
---     src = 'https://github.com/folke/todo-comments.nvim',
---     cond = ar.get_plugin_cond('todo-comments.nvim'),
---     cmd = { 'TodoQuickFix' },
---     keys = {
---       { '<leader>tq', '<Cmd>TodoQuickFix<CR>', desc = 'Todo quickfix' },
---     },
---     dependencies = {
---       { src = 'https://github.com/nvim-lua/plenary.nvim' },
---     },
---     setup = function()
---       require('todo-comments').setup({ signs = false })
---     end,
---   })
--- ```
---
--- A list uses the same spec format for each entry:
--- ```lua
---   ar.pack.add({
---     { src = 'https://github.com/stevearc/oil.nvim' },
---     { src = 'https://github.com/folke/todo-comments.nvim' },
---   })
--- ```
---@param specs PackSpec|PackSpec[]
function ar.pack.add(specs)
  local order, seen = {}, {}
  if specs.src then
    collect_spec(specs, false, order, seen)
  else
    for _, spec in ipairs(specs) do
      collect_spec(spec, false, order, seen)
    end
  end
  for _, state in ipairs(order) do
    prepare_spec(state)
  end
  for _, state in ipairs(order) do
    local lazy = state.spec.lazy
    if lazy == nil then lazy = state.default_lazy end
    if not lazy and not state.preparing then
      load_spec(state.spec, { kind = 'eager' })
    end
  end
end

require('ar.core.pack.update-status').setup()
ar.pack.setup_checker()
