require("user.lsp.manager").setup "graphql"

vim.cmd [[setlocal comments=:#]]
vim.cmd [[setlocal commentstring=#\ %s]]
vim.cmd [[setlocal formatoptions-=t]]
vim.cmd [[setlocal iskeyword+=$,@-@]]
vim.cmd [[setlocal nospell]]

-- let b:undo_ftplugin = 'setlocal com< cms< fo< isk< sts< sw< et<'
