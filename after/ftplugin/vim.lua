vim.opt_local.iskeyword:append(':,#')
vim.wo.foldmethod = 'marker'
vim.opt_local.spell = true

if not rvim then return end
rvim.nnoremap('so', ":source % <bar> :lua vim.notify('Sourced ' .. vim.fn.expand('%'))<CR>")
