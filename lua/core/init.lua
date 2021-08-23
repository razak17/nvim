local defer = function()
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

local function load_plugins()
  local plug = require "core.plugins"
  plug.ensure_plugins()
  plug.commands()
  plug.load_compile()
end

local load_core = function()
  require "core.opts"
  if rvim.plugin_loaded "zephyr-nvim" then
    require "core.highlights"
    require "core.whitespace"
  end
  require("core.binds").setup()
  require("core.commands").setup()
end

require "core.globals"
require "core.config"

defer()
load_plugins()
load_core()
