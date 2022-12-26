if not rvim then return end
----------------------------------------------------------------------------------------------------
-- Set Providers & Disable Builtins
----------------------------------------------------------------------------------------------------
vim.g.python3_host_prog = rvim.path.python3
vim.g.node_host_prog = rvim.path.node
for _, v in pairs(rvim.util.disabled_providers) do
  vim.g['loaded_' .. v .. '_provider'] = 0
end
for _, plugin in pairs(rvim.util.disabled_builtins) do
  vim.g['loaded_' .. plugin] = 1
end
----------------------------------------------------------------------------------------------------
-- Load Modules
----------------------------------------------------------------------------------------------------
-- NOTE: order matters
R('user.core.lazy').ensure_plugins()
R('user.core.highlights')
R('user.core.commands')
----------------------------------------------------------------------------------------------------
-- Append RTP
----------------------------------------------------------------------------------------------------
local runtime_dir = rvim.get_runtime_dir()
local config_dir = rvim.get_config_dir()

vim.opt.rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site'))
vim.opt.rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site', 'after'))
vim.opt.rtp:prepend(join_paths(runtime_dir, 'site'))
vim.opt.rtp:append(join_paths(runtime_dir, 'site', 'after'))

vim.opt.rtp:remove(vim.call('stdpath', 'config'))
vim.opt.rtp:remove(join_paths(vim.call('stdpath', 'config'), 'after'))
vim.opt.rtp:prepend(config_dir)
vim.opt.rtp:append(join_paths(config_dir, 'after'))

vim.cmd([[let &packpath = &runtimepath]])
