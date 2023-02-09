if not rvim then return end

local rtp = vim.opt.rtp

----------------------------------------------------------------------------------------------------
-- Append RTP
----------------------------------------------------------------------------------------------------
rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site'))
rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site', 'after'))
rtp:prepend(join_paths(rvim.get_runtime_dir(), 'site', 'after'))
rtp:append(join_paths(rvim.get_runtime_dir(), 'site', 'pack', 'lazy'))

rtp:remove(vim.call('stdpath', 'config'))
rtp:remove(join_paths(vim.call('stdpath', 'config'), 'after'))
rtp:prepend(rvim.get_config_dir())
rtp:append(join_paths(rvim.get_config_dir(), 'after'))

vim.cmd([[let &packpath = &runtimepath]])

----------------------------------------------------------------------------------------------------
-- Load Modules
----------------------------------------------------------------------------------------------------
R('user.config.defaults')
R('user.config.settings')
R('user.config.styles')
R('user.config.lsp')
