local api, fs = vim.api, vim.fs
local is_git = ar.is_git_repo() or ar.is_git_env()

local M = {}

local git_cache = {} ---@type table<string, boolean>
local function is_git_root(dir)
  if git_cache[dir] == nil then
    git_cache[dir] = vim.uv.fs_stat(dir .. '/.git') ~= nil
  end
  return git_cache[dir]
end

-- https://github.com/folke/snacks.nvim/blob/bc0630e43be5699bb94dadc302c0d21615421d93/lua/snacks/git.lua?plain=1#L25
--- Gets the git root for a buffer or path.
--- Defaults to the current buffer.
---@param path? number|string buffer or path
---@return string?
function M.get_root(path)
  path = path or 0
  path = type(path) == 'number' and api.nvim_buf_get_name(path) or path --[[@as string]]
  path = fs.normalize(path)
  path = path == '' and vim.uv.cwd() or path

  local todo = { path } ---@type string[]
  for dir in fs.parents(path) do
    table.insert(todo, dir)
  end

  -- check cache first
  for _, dir in ipairs(todo) do
    if git_cache[dir] then return fs.normalize(dir) or nil end
  end

  for _, dir in ipairs(todo) do
    if is_git_root(dir) then return fs.normalize(dir) or nil end
  end

  return vim.env.GIT_WORK_TREE
end

---@param plugin string plugin name
function M.git_cond(plugin)
  local condition = ar.git.enable and is_git
  return ar.get_plugin_cond(plugin, condition)
end

return M
