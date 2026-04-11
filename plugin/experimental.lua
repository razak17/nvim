if not ar then return end

if not ar.has('nvim-treesitter') then return end

local variant = ar.config.ui.cmdline.variant

if not vim.tbl_contains({ 'extui', 'tiny-cmdline' }, variant) then return end

vim.o.cmdheight = 0

require('vim._core.ui2').enable({ enable = true, msg = { target = 'msg' } })
