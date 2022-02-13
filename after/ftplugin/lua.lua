require("user.lsp.manager").setup "sumneko_lua"

vim.cmd [[setlocal iskeyword+="]]
vim.cmd [[setlocal textwidth=100]]
vim.cmd [[setlocal formatoptions-=o]]

vim.cmd [[
  let b:surround_{char2nr('F')} = "function \1function: \1() \r end"
  let b:surround_{char2nr('i')} = "if \1if: \1 then \r end"
]]
