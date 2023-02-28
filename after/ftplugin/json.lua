vim.bo.autoindent = true
vim.wo.conceallevel = 0
vim.bo.expandtab = true
vim.wo.foldmethod = 'syntax'
vim.bo.formatoptions = 'tcq2l'
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2

local filename = vim.fn.expand('%:t')
if filename ~= 'package.json' then return end

require('which_key').register({ ['<localleader>'] = { p = { name = 'Package Info' } } })
local with_desc = function(desc) return { buffer = 0, desc = desc } end
local package_info = require('package-info')
map('n', '<localleader>pt', package_info.toggle, with_desc('package-info: toggle'))
map('n', '<localleader>pu', package_info.update, with_desc('package-info: update'))
map('n', '<localleader>pd', package_info.delete, with_desc('package-info: delete'))
map('n', '<localleader>pi', package_info.install, with_desc('package-info: install new'))
map('n', '<localleader>pc', package_info.change_version, with_desc('package-info: change version'))
