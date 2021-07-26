local dap = require "dap"
vim.fn.sign_define("DapBreakpoint", {text = "🛑", texthl = "", linehl = "", numhl = ""})
vim.fn.sign_define("DapStopped", {text = "🟢", texthl = "", linehl = "", numhl = ""})
dap.defaults.fallback.terminal_win_cmd = "50vsplit new"

dap.configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
    host = function()
      local value = vim.fn.input "Host [127.0.0.1]: "
      if value ~= "" then
        return value
      end
      return "127.0.0.1"
    end,
    port = function()
      local val = tonumber(vim.fn.input "Port: ")
      assert(val, "Please provide a port number")
      return val
    end,
  },
}

dap.adapters.nlua = function(callback, config)
  callback {type = "server", host = config.host, port = config.port}
end

dap.configurations.javascript = {
  {
    type = 'node2',
    request = 'launch',
    program = '${workspaceFolder}/${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
}

dap.adapters.node2 = {type = 'executable', command = 'node', args = {rvim.__dap_node}}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      local cwd = vim.fn.getcwd()
      if rvim._exists(cwd .. '/venv/bin/python') then
        return cwd .. '/venv/bin/python'
      elseif rvim._exists(cwd .. '/.venv/bin/python') then
        return cwd .. '/.venv/bin/python'
      else
        return rvim.__dap_python
      end
    end,
  },
}

dap.adapters.python = {
  type = 'executable',
  command = rvim.__dap_python,
  args = {'-m', 'debugpy.adapter'},
}

dap.configurations.cpp = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    runInTerminal = false,
  },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

dap.adapters.lldb = {type = 'executable', command = '/usr/bin/lldb-vscode', name = "lldb"}

rvim.augroup("DapBehavior", {
  {
    events = {"FileType"},
    targets = {"dapui_scopes", "dapui_breakpoints", "dapui_stacks", "dapui_watches"},
    command = "set laststatus=0",
  },
})
