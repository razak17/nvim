require "core.globals"
require "core.config"

local function load_core()
  require "core.opts"
  require "core.highlights"
  require "keymap"
  require "core.binds"
end

local function load_plugins()
  local plug = require "core.plug"
  plug.ensure_plugins()
  plug.load_compile()
end

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

defer()
load_plugins()
load_core()
