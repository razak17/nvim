local enabled = ar_config.plugin.main.pack.enable

if not ar or ar.none or not enabled then return end

vim.cmd('packadd nvim.undotree')
vim.cmd('packadd nvim.difftool')
