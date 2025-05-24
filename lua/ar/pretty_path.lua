local fn, uv = vim.fn, vim.uv
local M = {}

---@return string
function M.norm(path)
  if path:sub(1, 1) == '~' then
    local home = uv.os_homedir()
    if not home or home == '' then return path end
    if home:sub(-1) == '\\' or home:sub(-1) == '/' then
      home = home:sub(1, -2)
    end
    path = home .. path:sub(2)
  end
  path = path:gsub('\\', '/'):gsub('/+', '/')
  return path:sub(-1) == '/' and path:sub(1, -2) or path
end

function M.root_cwd()
  local path = uv.cwd()
  if path == '' or path == nil then return nil end
  path = uv.fs_realpath(path) or path
  return M.norm(path)
end

function M.pretty_path()
  local opts = { relative = 'cwd', length = 3 }

  local path = fn.expand('%:p') --[[@as string]]

  if path == '' then return '' end

  path = M.norm(path)
  local root = uv.cwd()
  local cwd = M.root_cwd()

  if opts.relative == 'cwd' and path:find(cwd, 1, true) == 1 then
    path = path:sub(#cwd + 2)
  elseif path:find(root, 1, true) == 1 then
    path = path:sub(#root + 2)
  end

  local sep = package.config:sub(1, 1)
  local parts = vim.split(path, '[\\/]')

  if opts.length == 0 then
    parts = parts
  elseif #parts > opts.length then
    parts = { parts[1], '…', unpack(parts, #parts - opts.length + 2, #parts) }
  end

  local dir = ''
  if #parts > 1 then
    dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
    dir = dir .. sep
  end
  local name = parts[#parts] or ''
  if name:len() > 10 then name = ar.abbreviate(name) end
  return dir .. name
end

return M
