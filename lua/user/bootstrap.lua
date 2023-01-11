if not rvim then return end

----------------------------------------------------------------------------------------------------
-- Append RTP
----------------------------------------------------------------------------------------------------
vim.opt.rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site'))
vim.opt.rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site', 'after'))
vim.opt.rtp:prepend(join_paths(rvim.get_runtime_dir(), 'site', 'after'))
vim.opt.rtp:append(join_paths(rvim.get_runtime_dir(), 'site', 'pack', 'lazy'))

vim.opt.rtp:remove(vim.call('stdpath', 'config'))
vim.opt.rtp:remove(join_paths(vim.call('stdpath', 'config'), 'after'))
vim.opt.rtp:prepend(rvim.get_config_dir())
vim.opt.rtp:append(join_paths(rvim.get_config_dir(), 'after'))

vim.cmd([[let &packpath = &runtimepath]])

----------------------------------------------------------------------------------------------------
-- Load Modules
----------------------------------------------------------------------------------------------------
R('user.config.defaults')
R('user.config.settings')
R('user.config.style')
R('user.config.lsp')
