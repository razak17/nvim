vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25
vim.g.netrw_altv = 1
vim.g.netrw_fastbrowse = 0

vim.opt_local.bufhidden = 'wipe'

local with_desc = function(desc) return { buffer = 0, desc = desc } end
-- FIX: These mappings are not working
rvim.nnoremap('q', ':q<CR>', with_desc('quit'))
rvim.nnoremap('l', '<CR>', with_desc('open'))
rvim.nnoremap('h', '<CR>', with_desc('open'))
rvim.nnoremap('o', '<CR>', with_desc('open'))
