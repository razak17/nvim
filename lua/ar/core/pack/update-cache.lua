local M = {}
local loaded = {}

local function path()
  local lock = vim.fn.fnamemodify(vim.fn.expand(vim.o.packlockfile), ':p')
  return vim.fs.joinpath(
    vim.fn.stdpath('state'),
    'ar-pack',
    'updates',
    vim.fn.sha256(lock) .. '.json'
  )
end

function M.key(record)
  return vim.fn.sha256(
    table.concat({ record.src, record.name, record.path }, '\0')
  )
end

local function valid(record)
  if type(record) ~= 'table' then return false end
  for _, field in ipairs({ 'src', 'name', 'path' }) do
    if type(record[field]) ~= 'string' then return false end
  end
  if
    type(record.checked_at) ~= 'number'
    or record.checked_at <= 0
    or record.checked_at ~= record.checked_at
    or record.checked_at == math.huge
  then
    return false
  end
  for _, field in ipairs({ 'inventory_revision', 'constraint', 'error', 'from' }) do
    if record[field] ~= nil and type(record[field]) ~= 'string' then
      return false
    end
  end
  if record.status ~= 'error' then
    if
      record.status ~= 'available'
      and record.status ~= 'current'
      and record.status ~= 'updated'
    then
      return false
    end
    for _, field in ipairs({ 'current', 'target' }) do
      if
        type(record[field]) ~= 'string'
        or not record[field]:match('^%x%x%x%x%x%x%x%x*$')
      then
        return false
      end
    end
  end
  if record.commits ~= nil then
    if type(record.commits) ~= 'table' or not vim.islist(record.commits) then
      return false
    end
    for _, commit in ipairs(record.commits) do
      if type(commit) ~= 'string' then return false end
    end
  end
  return true
end

local function read(file)
  local ok, data = pcall(
    function() return vim.json.decode(table.concat(vim.fn.readfile(file), '\n')) end
  )
  local records = {}
  if
    ok
    and type(data) == 'table'
    and data.version == 1
    and type(data.records) == 'table'
  then
    for key, record in pairs(data.records) do
      if valid(record) and M.key(record) == key then records[key] = record end
    end
  end
  return records
end

function M.get(entry)
  local file = path()
  if not loaded[file] then loaded[file] = read(file) end
  local record = loaded[file][M.key(entry)]
  if
    not record
    or record.inventory_revision ~= entry.revision
    or record.constraint ~= entry.constraint
  then
    return
  end
  record = vim.deepcopy(record)
  -- Restart advice belongs to the process that actually applied the update.
  record.needs_restart = nil
  return record
end

function M.save(records)
  local file = path()
  -- Merge completed entries so another editor's unrelated checks survive.
  local saved, changed = read(file), false
  for _, record in pairs(records) do
    if valid(record) then
      saved[M.key(record)] = vim.deepcopy(record)
      changed = true
    end
  end
  if not changed then return end
  loaded[file] = saved
  local temporary = file .. '.' .. vim.uv.os_getpid() .. '.' .. vim.uv.hrtime()
  local ok, err = pcall(function()
    vim.fn.mkdir(vim.fs.dirname(file), 'p')
    assert(
      vim.fn.writefile(
        { vim.json.encode({ version = 1, records = saved }) },
        temporary
      ) == 0,
      'Could not write update cache'
    )
    assert(vim.uv.fs_rename(temporary, file))
  end)
  if not ok then
    vim.fn.delete(temporary)
    vim.notify(
      'Could not save package update results: ' .. tostring(err),
      vim.log.levels.WARN
    )
  end
end

return M
