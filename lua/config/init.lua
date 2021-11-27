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
  local default_config = require "config.defaults"

  for k, v in pairs(default_config) do
    rvim[k] = vim.deepcopy(v)
  end

  local lsp_config = require "lsp.config"
  rvim.lsp = vim.deepcopy(lsp_config)

  local plugins_config = require "core.plugins_config"
  rvim.plugin = vim.deepcopy(plugins_config)

  local which_key_config = require "modules.completion.which_key.config"
  rvim.wk = vim.deepcopy(which_key_config)

  local supported_languages = require "config.supported_languages"
  require("lsp.manager").init_defaults(supported_languages)

  require "config.mappings"
end

function M:load()
  require("core.bootstrap"):init()
  require "config.globals"
  M:init()

  defer()
  require("core.opts").setup()
  require "core.highlights"
  require "core.whitespace"

  local plug = require "core.plugins"
  plug.ensure_plugins()
  plug.load_compile()

  require("core.commands").setup()

  require("config.keymaps").setup()
end

return M
