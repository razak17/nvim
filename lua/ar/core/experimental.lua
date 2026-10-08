if not ar then return end

local has_query, _ = pcall(vim.treesitter.query.get, 'lua', 'highlights')

if not has_query then return end

local variant = ar.config.ui.cmdline.variant

if not vim.tbl_contains({ 'extui', 'tiny-cmdline' }, variant) then return end

vim.o.cmdheight = 0

require('vim._core.ui2').enable({ enable = true, msg = { target = 'msg' } })
