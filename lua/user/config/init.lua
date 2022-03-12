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

  rvim.packer_compile_path = rvim.get_runtime_dir() .. "/site/lua/_compiled_rolling.lua"

  require("user.lsp.manager").init_defaults()
end

function M:load()
  local g = vim.g

  g.python3_host_prog = rvim.python_path
  g.node_host_prog = rvim.node_path

  g["loaded_python_provider"] = 0
  g["loaded_ruby_provider"] = 0
  g["loaded_perl_provider"] = 0

  if rvim.defer then
    vim.cmd [[syntax off]]
    vim.cmd [[filetype off]]
    defer()
  end

  vim.g.colors_name = rvim.colorscheme
  vim.cmd("colorscheme " .. rvim.colorscheme)

  require("user.core.settings"):init()

  require "user.core.keymaps"

  require "user.core.commands"
  local plug = require "user.core.plugins"
  plug.ensure_installed()
  plug.load_compile()
end

return M
