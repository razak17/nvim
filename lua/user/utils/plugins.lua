local fn = vim.fn
local fmt = string.format

local M = {}

function M.plug_notify(msg, level)
  if rvim.plugin_loaded('nvim-notify') then
    vim.notify(msg, level, { title = 'Packer' })
    return
  end
  print(msg)
end

---Some plugins are not safe to be reloaded because their setup functions
---are not idempotent. This wraps the setup calls of such plugins
---@param func fun()
function M.block_reload(func)
  if vim.g.packer_compiled_loaded then return end
  func()
end

---Require a plugin config
---@param dir string
---@param name string
---@return any
function M.load_conf(dir, name)
  local module_dir = fmt('user.modules.%s', dir)
  if dir == 'user' then return require(fmt(dir .. '.%s', name)) end

  return require(fmt(module_dir .. '.%s', name))
end

--- Automagically register local and remote plugins as well as managing when they are enabled or disabled
--- 1. Local plugins that I created should be used but specified with their git URLs so they are
--- installed from git on other machines
--- 2. If DEVELOPING is set to true then local plugins I contribute to should be loaded vs their
--- remote counterparts
---@param spec table
function M.with_local(spec)
  assert(type(spec) == 'table', fmt('spec must be a table', spec[1]))
  assert(spec.local_path, fmt('%s has no specified local path', spec[1]))

  local name = vim.split(spec[1], '/')[2]
  local path = M.dev(name)
  if fn.isdirectory(fn.expand(path)) < 1 then return spec, nil end
  local local_spec = {
    path,
    config = spec.config,
    setup = spec.setup,
    rocks = spec.rocks,
    opt = spec.local_opt,
    as = fmt('local-%s', name),
    disable = spec.disable,
  }

  spec.local_path = nil
  spec.local_cond = nil
  spec.local_disable = nil

  return spec, local_spec
end

---local variant of packer's use function that specifies both a local and
---upstream version of a plugin
---@param original table
function M.use_local(original)
  local use = require('packer').use
  local spec, local_spec = M.with_local(original)
  if local_spec then
    use(local_spec)
  else
    -- NOTE: Don't install from repo is local is available
    use(spec)
  end
end

---@param path string
function M.dev(path) return join_paths(vim.env.HOME, 'personal/workspace/coding/plugins', path) end

return M
