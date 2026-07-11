local api, fn, fs = vim.api, vim.fn, vim.fs
local git_utils = require('ar.utils.git')

local M = {}

--- File renaming with LSP support
---@param from string
---@param to string
function M.on_rename_file(from, to)
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client:supports_method('workspace/willRenameFiles') then
      local resp = client.request_sync('workspace/willRenameFiles', {
        files = {
          {
            oldUri = vim.uri_from_fname(from),
            newUri = vim.uri_from_fname(to),
          },
        },
      }, 1000, 0)
      if resp and resp.result ~= nil then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end
end

-- https://github.com/folke/snacks.nvim/blob/bc0630e43be5699bb94dadc302c0d21615421d93/lua/snacks/picker/util/init.lua?plain=1#L17
---@param path string
---@param len? number
---@param opts? {cwd?: string}
function M.truncpath(path, len, opts)
  local cwd = fs.normalize(
    opts and opts.cwd or fn.getcwd(),
    { _fast = true, expand_env = false }
  )
  local home = fs.normalize('~')
  path = fs.normalize(path, { _fast = true, expand_env = false })

  if path:find(cwd .. '/', 1, true) == 1 and #path > #cwd then
    path = path:sub(#cwd + 2)
  else
    local root = git_utils.get_root(path)
    if root and root ~= '' and path:find(root, 1, true) == 1 then
      local tail = fn.fnamemodify(root, ':t')
      path = '⋮' .. tail .. '/' .. path:sub(#root + 2)
    elseif path:find(home, 1, true) == 1 then
      path = '~' .. path:sub(#home + 1)
    end
  end
  path = path:gsub('/$', '')

  if api.nvim_strwidth(path) <= len then return path end

  local parts = vim.split(path, '/')
  if #parts < 2 then return path end
  local ret = table.remove(parts)
  local first = table.remove(parts, 1)
  if first == '~' and #parts > 0 then first = '~/' .. table.remove(parts, 1) end
  local width = api.nvim_strwidth(ret) + api.nvim_strwidth(first) + 3
  while width < len and #parts > 0 do
    local part = table.remove(parts) .. '/'
    local w = api.nvim_strwidth(part)
    if width + w > len then break end
    ret = part .. ret
    width = width + w
  end
  return first .. '/…/' .. ret
end

--- Converts a value to a list
---@param value any # any value that will be converted to a list
---@return any[] # the listified version of the value
local function to_list(value)
  if value == nil then
    return {}
  elseif vim.islist(value) then
    return value
  elseif type(value) == 'table' then
    local list = {}
    for _, item in ipairs(value) do
      table.insert(list, item)
    end

    return list
  else
    return { value }
  end
end

local group_index = 0

--- Creates an auto command that triggers on a given list of events
--- Inside user_opts, you can specify the target buffer or pattern like so: { target = 123 } or { target = "pattern" } or { target = { "pattern1", "pattern2" } }...
---@param events string|string[] # the list of events to trigger on
---@param callback function # the callback to call when the event is triggered
---@param user_opts table|nil # opts of the auto command
---@return number # the group id of the created group
function M.on_event(events, callback, user_opts)
  assert(type(callback) == 'function')

  events = to_list(events)
  local group_name = user_opts
      and user_opts.desc
      and 'custom_' .. user_opts.desc:gsub(' ', '_'):lower() .. '_' .. group_index
    or 'custom_' .. group_index
  group_index = group_index + 1

  local group = vim.api.nvim_create_augroup(group_name, { clear = true })
  local opts = {
    callback = function(evt) callback(evt, group) end,
    group = group,
    desc = user_opts and user_opts.desc or 'Custom event',
  }

  if user_opts then
    local valid_opts = { 'target', 'desc' }
    for key in pairs(user_opts) do
      assert(vim.tbl_contains(valid_opts, key), 'Invalid option: ' .. key)
    end

    local target = user_opts.target
    if target then
      if type(target) == 'number' then
        opts.buffer = target
      else
        opts.pattern = to_list(target)
      end
    end
  end

  vim.api.nvim_create_autocmd(events, opts)
  return group
end

-- https://github.com/CRAG666/dotfiles/blob/27c915ea05c4a15171b4db16f6883f2de065ecec/config/nvim/lua/utils/fs.lua#L3
M.root_markers = {
  -- Must include python environment root markers here so that we can set cwd
  -- inside a python project and have correct python version in nvim.
  -- This is crucial for running pytest from within nvim using vim-test or
  -- other jobs that requires a python virtual environment.
  { 'venv', 'env', '.venv', '.env' },
  { '.python-version' },
  {
    '.git',
    '.svn',
    '.bzr',
    '.hg',
  },
  {
    '.project',
    '.pro',
    '.sln',
    '.vcxproj',
  },
  {
    'Makefile',
    'makefile',
    'MAKEFILE',
  },
  {
    '.gitignore',
    '.editorconfig',
  },
  {
    'README',
    'README.md',
    'README.txt',
    'README.org',
  },
}

local fs_root = vim.fs.root

---Wrapper of `vim.fs.root()` that accepts layered root markers like
---`vim.lsp.Config.root_markers`
---@param source? integer|string default to current working directory
---@param marker? (string|string[]|string[][]|fun(name: string, path: string): boolean) default to `utils.fs.root_markers`
---@return string?
function M.root(source, marker)
  source = source or 0
  marker = marker or M.root_markers

  if type(marker) ~= 'table' then return fs_root(source, marker) end

  local joined_markers = {} ---@type string[]

  for _, m in ipairs(marker) do
    -- `m` is a string, join with previous string markers as they are
    -- considered to have the same priority
    if type(m) == 'string' then
      table.insert(joined_markers, m)
      goto continue
    end

    -- `m` is a set of markers of the same priority, search them directly
    -- with `vim.fs.root()`, but before that we have to deal with previous
    -- unresolved marker set
    if not vim.tbl_isempty(joined_markers) then
      local root = fs_root(source, joined_markers)
      joined_markers = {}
      if root then return root end
    end

    local root = fs_root(source, m)
    if root then return root end
    ::continue::
  end
end

---Read file contents
---@param path string
---@return string?
function M.read_file(path)
  local file = io.open(path, 'r')
  if not file then return nil end
  local content = file:read('*a')
  file:close()
  return content or ''
end

---Write string into file
---@param path string
---@return boolean success
function M.write_file(path, str)
  local file = io.open(path, 'w')
  if not file then return false end
  file:write(str)
  file:close()
  return true
end

---Check if a path is empty
---@param path string
---@return boolean
function M.is_empty(path)
  local stat = vim.uv.fs_stat(path)
  return not stat or stat.size == 0
end

---Given a list of paths, return a list of path heads that uniquely distinguish each path
---e.g. { 'a/b/c', 'a/b/d', 'a/e/f' } -> { 'c', 'd', 'f' }
---     { 'a/b/c', 'd/b/c', 'e/c' } -> { 'a/b', 'd/b', 'e' }
---@param paths string[]
---@return string[]
function M.diff(paths)
  local n_paths = (function()
    local path_set = {}
    for _, path in ipairs(paths) do
      path_set[path] = true
    end
    return #vim.tbl_keys(path_set)
  end)()

  ---@alias ipath { [1]: string, [2]: integer }
  ---Paths with index
  ---@type ipath[]
  local ipaths = {}
  for i, path in ipairs(paths) do
    table.insert(ipaths, { path, i })
  end

  ---Groups of paths with the same tail
  ---key:val = tail:ihead[]
  ---@type table<string, ipath[]>
  local groups = { [''] = ipaths }

  while #vim.tbl_keys(groups) < n_paths do
    local g = {} ---@type table<string, ipath[]>
    for tail, iheads in pairs(groups) do
      for _, ihead in ipairs(iheads) do
        local head = ihead[1]
        local idx = ihead[2]
        local t = vim.fn.fnamemodify(head, ':t')
        local h = vim.fn.fnamemodify(head, ':h')
        if #vim.tbl_keys(groups) > 1 then
          t = t == '' and tail or tail == '' and t or vim.fs.joinpath(t, tail)
        end
        h = h == '.' and '' or h

        if not g[t] then g[t] = {} end
        table.insert(g[t], { h, idx })
      end
    end
    groups = g
  end

  local diffs = {}
  for tail, iheads in pairs(groups) do
    for _, ihead in ipairs(iheads) do
      diffs[ihead[2]] = tail
    end
  end
  return diffs
end

---Check if a given directory contains a file or subdirectory
---@param parent string directory path
---@param sub string sub file or directory path
---@param strict? boolean whether to return false if `parent` == `sub`, default false
function M.contains(parent, sub, strict)
  -- `fnamemodify()` adds trailing `/` to directories
  -- `parent` must end with `/`, else when `sub` is `/foo/bar-baz/file.txt` and
  -- `parent` is `/foo/bar`, the function gives false positive
  parent = vim.fn.fnamemodify(vim.fs.normalize(parent), ':p')
  sub = vim.fn.fnamemodify(vim.fs.normalize(sub), ':p')
  if strict and parent == sub then return false end
  return vim.startswith(sub, parent)
end

---Check if given directory is root directory
---@param dir string
---@return boolean
function M.is_root_dir(dir) return dir == vim.fs.dirname(dir) end

---Home directory
---@type string?
local home

---Check if given directory is home directory
---@param dir string
---@return boolean
function M.is_home_dir(dir)
  if not home then
    home = vim.uv.os_homedir()
    home = home and vim.fs.normalize(home)
  end
  return vim.fs.normalize(dir) == home
end

---Check if a path is full path
---@param path string
---@return boolean
function M.is_full_path(path)
  -- Use `fs.normalize()` to trim trailing slashes so that
  -- `foo/` and `foo` are treated equally
  return vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
    == vim.fs.normalize(path)
end

return M
