vim.cmd([[setlocal iskeyword+=:,#]])
vim.opt_local.foldmethod = 'marker'

if not rvim then return end
rvim.nnoremap('so', ":source % <bar> :lua vim.notify('Sourced ' .. vim.fn.expand('%'))<CR>")
