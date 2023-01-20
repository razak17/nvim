vim.bo.textwidth = 120
vim.opt_local.spell = true

local ok, which_key = rvim.safe_require('which-key', { silent = true })
if ok then which_key.register({ ['<localleader>'] = { r = { name = 'Rust Tools' } } }) end
