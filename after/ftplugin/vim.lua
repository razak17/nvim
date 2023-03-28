vim.opt_local.iskeyword:append(':,#')
vim.wo.foldmethod = 'marker'

if not rvim then return end
map('n', 'so', ":source % <bar> :lua vim.notify('Sourced ' .. vim.fn.expand('%'))<CR>")
