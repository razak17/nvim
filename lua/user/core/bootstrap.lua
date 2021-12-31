local M = {}

local uv = vim.loop
local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
  local result = table.concat({ ... }, path_sep)
  return result
end

---Get the full path to `$RVIM_RUNTIME_DIR`
---@return string
function _G.get_runtime_dir()
  local rvim_runtime_dir = os.getenv "RVIM_RUNTIME_DIR"
  if not rvim_runtime_dir then
    -- when nvim is used directly
    return vim.fn.stdpath "data"
  end
  return rvim_runtime_dir
end

---Get the full path to `$RVIM_CONFIG_DIR`
---@return string
function _G.get_config_dir()
  local rvim_config_dir = os.getenv "RVIM_CONFIG_DIR"
  if not rvim_config_dir then
    return vim.fn.stdpath "config"
  end
  return rvim_config_dir
end

---Get the full path to `$LUNARVIM_CACHE_DIR`
---@return string
function _G.get_cache_dir()
  local rvim_cache_dir = os.getenv "RVIM_CACHE_DIR"
  if not rvim_cache_dir then
    return vim.fn.stdpath "cache"
  end
  return rvim_cache_dir
end

---Get the full path to `$RVIM_CONFIG_DIR/user`
---@return string
function _G.get_user_dir()
  local config_dir = os.getenv "RVIM_CONFIG_DIR"
  if not config_dir then
    config_dir = vim.fn.stdpath "config"
  end
  local rvim_config_dir = require("user.utils").join_paths(config_dir, "lua/user/")
  return rvim_config_dir
end

function M:init()
  local H = os.getenv "HOME"
  local g, cmd = vim.g, vim.cmd
  local node_version = "17.3.0"

  g.python3_host_prog = get_cache_dir() .. "/venv/neovim/bin/python3"
  g.node_host_prog = H
    .. "/.fnm/node-versions/v"
    .. node_version
    .. "/installation/bin/neovim-node-host"

  g["loaded_python_provider"] = 0
  g["loaded_ruby_provider"] = 0
  g["loaded_perl_provider"] = 0

  self.runtime_dir = get_runtime_dir()
  self.config_dir = get_config_dir()
  self.cache_dir = get_cache_dir()
  self.user_dir = get_user_dir()

  vim.opt.rtp:remove(join_paths(vim.fn.stdpath "data", "site"))
  vim.opt.rtp:remove(join_paths(vim.fn.stdpath "data", "site", "after"))
  vim.opt.rtp:prepend(join_paths(self.runtime_dir, "site"))
  vim.opt.rtp:append(join_paths(self.runtime_dir, "site", "after"))

  vim.opt.rtp:remove(vim.fn.stdpath "config")
  vim.opt.rtp:remove(join_paths(vim.fn.stdpath "config", "after"))
  vim.opt.rtp:prepend(self.config_dir)
  vim.opt.rtp:append(join_paths(self.config_dir, "after"))

  cmd [[let &packpath = &runtimepath]]

  require("user.core.impatient").setup {
    path = join_paths(self.cache_dir, "rvim_cache"),
    enable_profiling = true,
  }
end

return M
