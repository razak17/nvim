return function()
  local debug = require "debug"
  -- local nnoremap = rvim.nnoremap

  debug.setup()

  -- nnoremap("<Leader>dso", ':lua require"dap".step_out()<CR>')
  -- nnoremap("<Leader>dsv", ':lua require"dap".step_over()<CR>')
  -- nnoremap("<Leader>dsi", ':lua require"dap".step_into()<CR>')
  -- nnoremap("<Leader>dsb", ':lua require"dap".step_back()<CR>')
  -- nnoremap("<leader>da", ':lua require"debug.utils".attach()<CR>')
  -- nnoremap("<leader>dA", ':lua require"debug.utils".attachToRemote()<CR>')
  -- nnoremap("<leader>db", ':lua require"dap".toggle_breakpoint()<CR>')
  -- nnoremap("<leader>dB", ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
  -- nnoremap("<leader>dc", ':lua require"dap".continue()<CR>')
  -- nnoremap("<leader>dC", ':lua require"dap".run_to_cursor()<CR>')
  -- nnoremap("<leader>dE", ':lua require"dap".repl.toggle()<CR>')
  -- nnoremap("<leader>dg", ':lua require"dap".session()<CR>')
  -- nnoremap("<leader>dk", ':lua require"dap".up()<CR>')
  -- nnoremap("<leader>dL", ':lua require"dap".run_last()<CR>')
  -- nnoremap("<leader>dn", ':lua require"dap".down()<CR>')
  -- nnoremap("<leader>dp", ':lua require"dap".pause.toggle()<CR>')
  -- nnoremap("<leader>dr", ':lua require"dap".repl.open({}, "vsplit")<CR><C-w>l')
  -- nnoremap("<leader>dS", ':lua require"dap".close()<CR>')
  -- nnoremap("<leader>dx", ':lua require"dap".disconnect()<CR>')
end
