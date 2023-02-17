local opt = vim.opt_local

opt.buflisted = false
opt.winfixheight = true
opt.signcolumn = 'yes'

if rvim then rvim.adjust_split_height(10, 15) end

-- Add autocompletion
require('dap.ext.autocompl').attach()
