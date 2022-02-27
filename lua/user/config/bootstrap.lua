local M = {}

local u = require "user.utils"

function M:init(base_dir)
  local cmd = vim.cmd

  self.runtime_dir = rvim.get_runtime_dir()
  self.config_dir = rvim.get_config_dir()
  self.cache_dir = rvim.get_cache_dir()
  self.user_dir = rvim.get_user_dir()

  ---Get the full path to rVim's base directory
  ---@return string
  function rvim.get_base_dir()
    return base_dir
  end

  if os.getenv "RVIM_RUNTIME_DIR" then
    vim.opt.rtp:remove(u.join_paths(vim.fn.stdpath "data", "site"))
    vim.opt.rtp:remove(u.join_paths(vim.fn.stdpath "data", "site", "after"))
    vim.opt.rtp:prepend(u.join_paths(self.runtime_dir, "site"))
    vim.opt.rtp:append(u.join_paths(self.runtime_dir, "site", "after"))

    vim.opt.rtp:remove(vim.fn.stdpath "config")
    vim.opt.rtp:remove(u.join_paths(vim.fn.stdpath "config", "after"))
    vim.opt.rtp:prepend(self.config_dir)
    vim.opt.rtp:append(u.join_paths(self.config_dir, "after"))
  end

  cmd [[let &packpath = &runtimepath]]

  require("user.core.impatient").setup {
    path = u.join_paths(self.cache_dir, "rvim_cache"),
    enable_profiling = true,
  }

  require("user.config"):init()
end

return M
