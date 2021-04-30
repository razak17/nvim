local mapk = vim.api.nvim_set_keymap

mapk("i", "<S-Tab>", 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
mapk("i", "<Tab>", 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
mapk("i", "<c-space>", [[ "\<Plug>(completion_trigger)" ]], {expr = true})
mapk("i", "<c-h>", [[ "\<Plug>(completion_next_source)" ]], {expr = true})
mapk("i", "<c-k>", [[ "\<Plug>(completion_prev_source)" ]], {expr = true})

-- Use completion-nvim in every buffer
vim.cmd('autocmd BufEnter * lua require"completion".on_attach()')



