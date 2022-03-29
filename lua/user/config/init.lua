local M = {}

function M:init()
  local default_config = require "user.config.defaults"
  for k, v in pairs(default_config) do
    rvim[k] = vim.deepcopy(v)
  end

  R "zephyr.palette"
  R "user.config.style"
  R "user.lsp.config"

  require("user.lsp.manager").init_defaults()
end

function M:load()
  local g = vim.g
  g.python3_host_prog = rvim.python_path
  g.node_host_prog = rvim.node_path
  for _, v in pairs(rvim.providers_disabled) do
    g["loaded_" .. v .. "_provider"] = 0
  end

  if rvim.defer then
    vim.cmd [[syntax off]]
    vim.cmd [[filetype off]]
    vim.defer_fn(
      vim.schedule_wrap(function()
        vim.defer_fn(function()
          vim.cmd [[syntax on]]
          vim.cmd [[filetype plugin indent on]]
        end, 0)
      end),
      0
    )
  end

  vim.g.colors_name = rvim.colorscheme
  vim.cmd("colorscheme " .. rvim.colorscheme)
  require("user.core.settings"):init()
  require "user.core.commands"
  require("user.core.plugins").ensure_installed()
end

return M
