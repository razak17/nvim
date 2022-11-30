vim.bo.autoindent = true
vim.wo.conceallevel = 0
vim.bo.expandtab = true
vim.wo.foldmethod = 'syntax'
vim.bo.formatoptions = 'tcq2l'
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
-- json 5 comment
vim.cmd([[syntax region Comment start="//" end="$" |]])
vim.cmd([[syntax region Comment start="/\*" end="\*/" |]])

if not rvim.plugin_loaded('package-info.nvim') then return end

local nnoremap = rvim.nnoremap
local with_desc = function(desc) return { buffer = 0, desc = desc } end
local package_info = require('package-info')

nnoremap('<localleader>pt', package_info.toggle, with_desc('package-info: toggle'))
nnoremap('<localleader>pu', package_info.update, with_desc('package-info: update'))
nnoremap('<localleader>pd', package_info.delete, with_desc('package-info: delete'))
nnoremap('<localleader>pi', package_info.install, with_desc('package-info: install new'))
nnoremap('<localleader>pc', package_info.change_version, with_desc('package-info: change version'))
