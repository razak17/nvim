vim.opt_local.colorcolumn = 120
vim.cmd([[setlocal iskeyword+=:,#]])
vim.opt_local.foldmethod = 'marker'
rvim.nnoremap('so', ":source % <bar> :lua vim.notify('Sourced ' .. vim.fn.expand('%'))<CR>")
