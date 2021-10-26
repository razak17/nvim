local M = {}

function M:init()
  require("config"):load()

  local plug = require("core.plugins")
  plug.ensure_plugins()
  plug.load_compile()

  require("core.binds").setup()
  require("core.commands").setup()
end

return M
