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
  if rvim.common.defer then
    vim.cmd [[syntax off]]
    vim.cmd [[filetype off]]
    defer()
  end

  vim.g.colors_name = rvim.common.colorscheme
  vim.cmd("colorscheme " .. rvim.common.colorscheme)

  require("user.core.opts"):init()

  require "user.core.whitespace"

  require("user.core.commands"):init()

  require("user.config.keymaps"):init()
end

return M
