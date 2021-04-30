local G = require "global"
local g =  vim.g
local opts = {noremap = true, silent = true}
local mapk = vim.api.nvim_set_keymap

g["vsnip_snippet_dir"] = G.vim_path .. "snippets"

-- NOTE: You can use other key to expand snippet.

-- Expand
mapk('i', '<expr><C-l>', 'vsnip#expandable() ? "<Plug>(vsnip-expand)" : "<C-l>"', opts)
mapk('s', '<expr><C-l>', 'vsnip#expandable() ? "<Plug>(vsnip-expand)" : "<C-l>"', opts)

-- Expand or jump
mapk('i', '<expr><C-l>', 'vsnip#available(1) ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"', opts)
mapk('s', '<expr><C-l>', 'vsnip#available(1) ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"', opts)

-- Jump forward or backward
mapk('i', '<expr><Tab>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<Tab>"', opts)
mapk('s', '<expr><Tab>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<Tab>"', opts)
mapk('i', '<expr><S-Tab>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<S-Tab>"', opts)
mapk('s', '<expr><S-Tab>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<S-Tab>"', opts)

-- If you want to use snippet for multiple filetypes, you can `g:vsip_filetypes` for it.
-- let g:vsnip_filetypes = {}
-- let g:vsnip_filetypes.javascriptreact = ['javascript']
-- let g:vsnip_filetypes.typescriptreact = ['typescript']
