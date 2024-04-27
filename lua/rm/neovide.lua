vim.g.neovide_scale_factor = 1.0
vim.g.neovide_remember_window_size = true
vim.g.neovide_cursor_vfx_mode = 'railgun'
-- vim.opt.guifont = { 'Operator Mono SSm Lig Book:h8', ':h14' }
vim.o.guifont = 'Operator Mono SSm Lig Book:h8' -- text below applies for VimScript
vim.g.neovide_input_macos_alt_is_meta = true
vim.opt.linespace = 0

vim.api.nvim_set_keymap("n", "<C-+>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 0.9<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>", { silent = true })
