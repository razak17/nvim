require("lsp.manager").setup "gopls"

-----------------------------------------------------------------------------//
-- GO FILE SETTINGS
-----------------------------------------------------------------------------//
vim.cmd [[setlocal shiftwidth=4]]
vim.cmd [[setlocal softtabstop=4]]
vim.cmd [[setlocal tabstop=4]]
vim.cmd [[setlocal noexpandtab]]
vim.cmd [[setlocal textwidth=100]]
vim.cmd [[setlocal iskeyword+="]]

rvim.nnoremap("<leader>cf", ":<cmd>call utils#create_go_doc_comment()<CR><CR>")
