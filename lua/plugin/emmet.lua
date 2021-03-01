local vim = vim

vim.g.user_emmet_leader_key='<C-y>'

vim.g.user_emmet_mode='a'
vim.g.user_emmet_install_global = 0
vim.cmd('autocmd FileType html,css EmmetInstall')
