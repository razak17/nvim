local dap = require "dap"
local M = {}

function M.setup()
  dap.adapters.nlua = function(callback, config)
    callback { type = "server", host = config.host, port = config.port }
  end

  -- Lua
  dap.configurations.lua = {
    {
      type = "nlua",
      request = "attach",
      name = "Attach to running Neovim instance",
      host = function()
        local value = vim.fn.input "Host [127.0.0.1]: "
        return value ~= "" and value or "127.0.0.1"
      end,
      port = function()
        local val = tonumber(vim.fn.input "Port: ")
        assert(val, "Please provide a port number")
        return val
      end,
    },
  }
end

return M
