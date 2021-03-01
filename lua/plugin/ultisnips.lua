local snip_path = vim.fn.stdpath('config')..'/snips'
local opts = {noremap = true, silent = true}
local map = vim.api.nvim_set_keymap

vim.g.UltiSnipsSnippetDirectories={ snip_path }
vim.g.UltiSnipsExpandTrigger="<c-l>"
vim.g.UltiSnipsJumpForwardTrigger="<c-l>"
vim.g.UltiSnipsJumpBackwardTrigger="<c-b>"

map('n', '<Leader>cs', ':UltiSnipsEdit<CR>', opts)
