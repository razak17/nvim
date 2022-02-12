return function()
  local dap = require "dap"

  rvim.dap = {
    install_dir = rvim.get_cache_dir() .. "/dap",
    python_dir = rvim.get_cache_dir() .. "/dap/python_dbg/bin/python",
    node_dir = rvim.get_cache_dir() .. "/dap/jsnode_dbg/vscode-node-debug2/out/src/nodeDebug.js",
    breakpoint = {
      text = "",
      texthl = "LspDiagnosticsSignError",
      linehl = "",
      numhl = "",
    },
    breakpoint_rejected = {
      text = "",
      texthl = "LspDiagnosticsSignHint",
      linehl = "",
      numhl = "",
    },
    stopped = {
      text = "",
      texthl = "LspDiagnosticsSignInformation",
      linehl = "DiagnosticUnderlineInfo",
      numhl = "LspDiagnosticsSignInformation",
    },
  }

  -- vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
  -- vim.fn.sign_define("DapStopped", { text = "🟢", texthl = "", linehl = "", numhl = "" })

  vim.fn.sign_define("DapBreakpoint", rvim.dap.breakpoint)
  vim.fn.sign_define("DapBreakpointRejected", rvim.dap.breakpoint_rejected)
  vim.fn.sign_define("DapStopped", rvim.dap.stopped)

  dap.defaults.fallback.terminal_win_cmd = "50vsplit new"

  -- COnfiguration
  require("user.dap.lua").setup()

  require("user.dap.node").setup()

  require("user.dap.python").setup()

  require("user.dap.lldb").setup()

  -- Keymaps
  require("which-key").register {
    ["<leader>d"] = {
      name = "+Debug",
      ["?"] = {
        ':lua local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes)<CR>',
        "scopes",
      },
      a = { ':lua require"user.dap.utils".attach()<cr>', "attach" },
      A = { ':lua require"user.dap.utils".attachToRemote()<cr>', "attach remote" },

      h = { ":lua require'dap'.step_back()<cr>", "step back" },
      i = { ":lua require'dap'.step_into()<cr>", "step into" },
      u = { ":lua require'dap'.step_out()<cr>", "step out" },
      o = { ":lua require'dap'.step_over()<cr>", "step over" },

      t = { ":lua require'dap'.toggle_breakpoint()<cr>", "toggle breakpoint" },
      T = {
        ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<cr>',
        "set breakpoint",
      },

      c = { ":lua require'dap'.continue()<cr>", "continue" },
      C = { ":lua require'dap'.clear_breakpoints()<cr>", "clear breakpoints" },
      e = { ":lua require'dap'.set_exception_breakpoints({'all'})<cr>", "breakpoint exception" },
      n = { ":lua require'dap'.run_to_cursor()<cr>", "run to cursor" },
      K = { ":lua require'dap.ui.widgets'.hover()<cr>", "hover" },

      [";"] = { ":lua require'dap'.repl.toggle()<cr>", "toggle repl" },
      R = { ':lua require"dap".repl.open({}, "vsplit")<cr><C-w>l<cr>', "open repl in vsplit" },

      x = { ":lua require'dap'.disconnect()<cr>", "disconnect" },
      z = { ":lua require'dap'.terminate()<cr>", "terminate" },
      g = { ":lua require'dap'.session()<cr>", "get session" },
      q = { ":lua require'dap'.close()<cr>", "quit" },

      k = { ":lua require'dap'.up()<cr>", "up" },
      j = { ":lua require'dap'.down()<cr>", "down" },
      l = { ":lua require'dap'.run_last()<cr>", "run last" },
      p = { ":lua require'dap'.pause.toggle()<cr>", "pause" },

      f = { ":Telescope dap frames<cr>", "frames" },
      v = { ":Telescope dap variables<cr>", "variables" },
      b = { ":Telescope dap list_breakpoints<cr>", "list breakpoints" },
    },
  }

  -- Autocommands
  rvim.augroup("DapBehavior", {
    {
      events = { "FileType" },
      targets = { "dapui_scopes", "dapui_breakpoints", "dapui_stacks", "dapui_watches" },
      command = "set laststatus=0",
    },
  })
end
