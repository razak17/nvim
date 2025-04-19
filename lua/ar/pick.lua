-- Ref: https://github.com/LazyVim/LazyVim/blame/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/util/pick.lua#L1

---@class ar.pick
---@overload fun(command:string, opts?:ArPickOpts): fun()
local M = setmetatable({}, {
  __call = function(m, ...) return m.wrap(...) end,
})

local L = vim.log.levels

---@class ArPickOpts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number
---@field show_untracked? boolean
---@field follow? boolean
---@field extension? string
---@field scope? table

---@class ArPick
---@field name string
---@field open fun(command:string, opts?:ArPickOpts)
---@field commands table<string, string>

---@type ArPick?
M.picker = nil

---@param picker ArPick
function M.register(picker)
  if M.picker and M.picker.name ~= picker.name then
    vim.notify(
      '`pick`: picker already set to `'
        .. M.picker.name
        .. '`,\nignoring new picker `'
        .. picker.name
        .. '`',
      L.WARN
    )
    return false
  end
  M.picker = picker
  return true
end

---@param command? string
---@param opts? ArPickOpts
function M.open(command, opts)
  if not M.picker then return vim.notify('pick: picker not set', L.ERROR) end

  command = command ~= 'auto' and command or 'files'
  opts = opts or {}

  opts = vim.deepcopy(opts)

  if type(opts.cwd) == 'boolean' then
    vim.notify('pick: opts.cwd should be a string or nil', L.WARN)
    opts.cwd = nil
  end

  if not opts.cwd and opts.root ~= false then
    opts.cwd = vim.fs.root(0, '.git')
  end

  command = M.picker.commands[command] or command
  M.picker.open(command, opts)
end

---@param command? string
---@param opts? ArPickOpts
function M.wrap(command, opts)
  opts = opts or {}
  return function() ar.pick.open(command, vim.deepcopy(opts)) end
end

function M.config_files()
  return M.wrap('files', { cwd = vim.fn.stdpath('config') })
end
return M
