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
R('user.core.commands')
R('user.core.highlights')
R('user.core.lazy').ensure_plugins()
