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

return M
