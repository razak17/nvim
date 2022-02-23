local M = {}

local utils = require "user.utils"

function M:init(base_dir)
  local H = os.getenv "HOME"
  local g, cmd = vim.g, vim.cmd
  local node_version = "17.3.0"

  g.python3_host_prog = rvim.get_cache_dir() .. "/venv/neovim/bin/python3"
  g.node_host_prog = H
    .. "/.fnm/node-versions/v"
    .. node_version
    .. "/installation/bin/neovim-node-host"

  g["loaded_python_provider"] = 0
  g["loaded_ruby_provider"] = 0
  g["loaded_perl_provider"] = 0

  self.runtime_dir = rvim.get_runtime_dir()
  self.config_dir = rvim.get_config_dir()
  self.cache_dir = rvim.get_cache_dir()
  self.user_dir = rvim.get_user_dir()

  ---Get the full path to rVim's base directory
  ---@return string
  function _G.get_rvim_base_dir()
    return base_dir
  end

  if os.getenv "RVIM_RUNTIME_DIR" then
    vim.opt.rtp:remove(utils.join_paths(vim.fn.stdpath "data", "site"))
    vim.opt.rtp:remove(utils.join_paths(vim.fn.stdpath "data", "site", "after"))
    vim.opt.rtp:prepend(utils.join_paths(self.runtime_dir, "site"))
    vim.opt.rtp:append(utils.join_paths(self.runtime_dir, "site", "after"))

    vim.opt.rtp:remove(vim.fn.stdpath "config")
    vim.opt.rtp:remove(utils.join_paths(vim.fn.stdpath "config", "after"))
    vim.opt.rtp:prepend(self.config_dir)
    vim.opt.rtp:append(utils.join_paths(self.config_dir, "after"))
  end

  cmd [[let &packpath = &runtimepath]]

  require("user.core.impatient").setup {
    path = utils.join_paths(self.cache_dir, "rvim_cache"),
    enable_profiling = true,
  }

  require("user.config"):init()

  local plug = require "user.core.plugins"
  plug.ensure_plugins()
  plug.load_compile()
end

return M
