local M = {}

local function defer()
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

function M:init()
  local default_config = require "user.config.defaults"

  for k, v in pairs(default_config) do
    rvim[k] = vim.deepcopy(v)
  end

  local palette = require "zephyr.palette"
  rvim.palette = vim.deepcopy(palette)

  local lsp_config = require "user.lsp.config"
  rvim.lsp = vim.deepcopy(lsp_config)

  local plugconfig = require "user.modules.config"
  rvim.plugin = vim.deepcopy(plugconfig)

  local which_key_config = require "user.modules.completion.which_key.config"
  rvim.wk = vim.deepcopy(which_key_config)

  require("user.lsp.manager").init_defaults()
end

function M:load()
  if rvim.common.defer then
    vim.cmd [[syntax off]]
    vim.cmd [[filetype off]]
    defer()
  end

  vim.g.colors_name = rvim.common.colorscheme
  vim.cmd("colorscheme " .. rvim.common.colorscheme)

  require("user.core.settings"):init()

  require "user.core.keymaps"

  require("user.utils.keymaps"):init(rvim.keymaps)

  require "user.core.commands"

  local plug = require "user.core.plugins"
  plug.ensure_plugins()
  plug.load_compile()
end

return M
