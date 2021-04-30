local dap = require 'dap'

dap.adapters.go = function(callback, config)
  local handle
  local pid_or_err
  local port = 38697
  handle, pid_or_err = vim.loop.spawn("dlv", {
    args = {"dap", "-l", "127.0.0.1:" .. port},
    detached = true
  }, function(code)
    handle:close()
    print("Delve exited with exit code: " .. code)
  end)

  dap.repl.open()
  callback({type = "server", host = "127.0.0.1", port = port})
end

dap.configurations.go = {
  {type = "go", name = "Debug", request = "launch", program = "${file}"}
}
