vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25
vim.g.netrw_altv = 1
vim.g.netrw_fastbrowse = 0

vim.opt_local.bufhidden = 'wipe'

local with_desc = function(desc) return { buffer = 0, desc = desc } end
-- FIX: These mappings are not working
map('n', 'q', ':q<CR>', with_desc('quit'))
map('n', 'l', '<CR>', with_desc('open'))
map('n', 'h', '<CR>', with_desc('open'))
map('n', 'o', '<CR>', with_desc('open'))
