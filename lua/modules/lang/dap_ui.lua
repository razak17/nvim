return function()
  vim.cmd [[packadd nvim-dap]]
  local vnoremap = rvim.vnoremap
  -- nnoremap('<leader>di', ':lua require"dap.ui.widgets".hover()<CR>')
  vnoremap("<leader>di", ':lua require"dap.ui.variables".visual_hover()<CR>')
  vnoremap("<leader>d?", ':lua local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes)<CR>')
  require("dapui").setup {
    mappings = { expand = "<CR>", open = "o", remove = "d" },
    sidebar = {
      open_on_start = true,
      elements = { "scopes", "breakpoints", "stacks", "watches" },
      width = 50,
      position = "left",
    },
    tray = { open_on_start = false, elements = { "repl" }, height = 10, position = "bottom" },
    floating = { max_height = 0.4, max_width = 0.4 },
  }
end
