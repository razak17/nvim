local M = {}

function M:defer()
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
  require "core.globals"
  require "core.config"

  require("core.opts").setup()
  require "core.highlights"
  require "core.whitespace"

  local plug = require("core.plugins")
  plug.ensure_plugins()
  plug.load_compile()

  require("core.binds").setup()
  require("core.commands").setup()
end

return M
