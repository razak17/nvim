return function()
  vim.cmd [[packadd lspsaga.nvim]]
  local saga = require "lspsaga"
  saga.init_lsp_saga {
    use_saga_diagnostic_sign = false,
    code_action_icon = "💡",
    code_action_prompt = { enable = false, sign = false, virtual_text = false },
  }
  local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap
  nnoremap("gd", ":Lspsaga lsp_finder<CR>")
  nnoremap("gsh", ":Lspsaga signature_help<CR>")
  nnoremap("gh", ":Lspsaga preview_definition<CR>")
  nnoremap("grr", ":Lspsaga rename<CR>")
  nnoremap("K", ":Lspsaga hover_doc<CR>")
  nnoremap("<Leader>va", ":Lspsaga code_action<CR>")
  vnoremap("<Leader>vA", ":Lspsaga range_code_action<CR>")
  nnoremap("<Leader>vdb", ":Lspsaga diagnostic_jump_prev<CR>")
  nnoremap("<Leader>vdn", ":Lspsaga diagnostic_jump_next<CR>")
  nnoremap("<Leader>vdl", ":Lspsaga show_line_diagnostics<CR>")
end

