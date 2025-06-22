local fn, uv = vim.fn, vim.uv
local root_util = require('ar.utils.root')

local M = {}

function M.root_cwd()
  local path = uv.cwd()
  if path == '' or path == nil then return nil end
  path = uv.fs_realpath(path) or path
  return ar.norm(path)
end

function M.pretty_path()
  local opts = { relative = 'cwd', length = 3 }

  local path = fn.expand('%:p') --[[@as string]]

  if path == '' then return '' end

  path = ar.norm(path)
  local root = root_util.get({ normalize = true })
  local cwd = root_util.cwd()

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
  return { dir = dir, name = name }
end

return M
