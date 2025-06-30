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
function M.to_list(value)
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

  events = M.to_list(events)
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
        opts.pattern = M.to_list(target)
      end
    end
  end

  vim.api.nvim_create_autocmd(events, opts)
  return group
end

return M
