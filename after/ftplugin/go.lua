vim.bo.expandtab = false
vim.bo.textwidth = 0 -- Go doesn't specify a max line length so don't force one
vim.bo.softtabstop = 0
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.opt_local.iskeyword:append('-')
vim.opt_local.spell = true

if not rvim then return end

local ok, which_key = rvim.safe_require('which-key')
if ok then which_key.register({ ['<localleader>g'] = { name = 'Gopher' } }) end
local with_desc = function(desc) return { buffer = 0, desc = desc } end
rvim.nnoremap('<localleader>gb', '<Cmd>GoBuild<CR>', with_desc('build'))
rvim.nnoremap('<localleader>gfs', '<Cmd>GoFillStruct<CR>', with_desc('fill struct'))
rvim.nnoremap('<localleader>gfp', '<Cmd>GoFixPlurals<CR>', with_desc('fix plurals'))
rvim.nnoremap('<localleader>gie', '<Cmd>GoIfErr<CR>', with_desc('if err'))
