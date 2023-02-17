local opt = vim.opt_local

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.matchpairs:append('<:>')
opt.indentkeys:remove('*<Return>') -- Fix quirkiness in indentation

vim.cmd([[setlocal tw=120 linebreak textwidth=0]]) -- Make lines longer, and don't break them automatically
