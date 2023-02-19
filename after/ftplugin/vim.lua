vim.opt_local.iskeyword:append(':,#')
vim.wo.foldmethod = 'marker'
vim.opt_local.spell = true

if not rvim then return end
map('n', 'so', ":source % <bar> :lua vim.notify('Sourced ' .. vim.fn.expand('%'))<CR>")
