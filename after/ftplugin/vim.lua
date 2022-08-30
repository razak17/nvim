vim.opt_local.iskeyword:append(":,#")
vim.wo.foldmethod = 'marker'

if not rvim then return end
rvim.nnoremap('so', ":source % <bar> :lua vim.notify('Sourced ' .. vim.fn.expand('%'))<CR>")
