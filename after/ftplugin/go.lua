local opt = vim.opt_local

opt.expandtab = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.iskeyword:append('-')
opt.spell = true

if not rvim then return end

local ok, which_key = rvim.safe_require('which-key')
if ok then which_key.register({ ['<localleader>g'] = { name = 'Gopher' } }) end
local with_desc = function(desc) return { buffer = 0, desc = desc } end
map('n', '<localleader>gb', '<Cmd>GoBuild<CR>', with_desc('build'))
map('n', '<localleader>gfs', '<Cmd>GoFillStruct<CR>', with_desc('fill struct'))
map('n', '<localleader>gfp', '<Cmd>GoFixPlurals<CR>', with_desc('fix plurals'))
map('n', '<localleader>gie', '<Cmd>GoIfErr<CR>', with_desc('if err'))
