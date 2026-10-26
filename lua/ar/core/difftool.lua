if not ar then return end

local enabled = ar.config.plugin.core.difftool.enable

if not ar or ar.none or not enabled then return end

vim.cmd('packadd nvim.difftool')
