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

  local palette = require "user.config.palette"
  rvim.palette = vim.deepcopy(palette)

  local lsp_config = require "user.lsp.config"
  rvim.lsp = vim.deepcopy(lsp_config)

  local plugins_config = require "user.core.plugins_config"
  rvim.plugin = vim.deepcopy(plugins_config)

  local which_key_config = require "user.modules.completion.which_key.config"
  rvim.wk = vim.deepcopy(which_key_config)

  require("user.lsp.manager").init_defaults()

  require "user.config.mappings"
end

function M:load()
  require("user.core.bootstrap"):init()
  require "user.config.globals"
  M:init()

  if rvim.common.defer then
    vim.cmd [[syntax off]]
    vim.cmd [[filetype off]]
    defer()
  end

  local Log = require "user.core.log"
  Log:debug "Starting Rvim"

  require("user.core.opts").setup()
  require "user.core.highlights"
  require "user.core.whitespace"

  local plug = require "user.core.plugins"
  plug.ensure_plugins()
  plug.load_compile()

  require("user.core.commands").setup()

  require("user.config.keymaps").setup()
end

return M
