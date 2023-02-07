if not rvim then return end

----------------------------------------------------------------------------------------------------
-- Set leader keys
----------------------------------------------------------------------------------------------------
vim.g.mapleader = (rvim.keys.leader == 'space' and ' ') or rvim.keys.leader
vim.g.maplocalleader = (rvim.keys.localleader == 'space' and ' ') or rvim.keys.localleader

----------------------------------------------------------------------------------------------------
-- Set Providers & Disable Builtins
----------------------------------------------------------------------------------------------------
vim.g.python3_host_prog = rvim.path.python3
for _, v in pairs(rvim.util.disabled_providers) do
  vim.g['loaded_' .. v .. '_provider'] = 0
end
for _, plugin in pairs(rvim.util.disabled_builtins) do
  vim.g['loaded_' .. plugin] = 1
end

----------------------------------------------------------------------------------------------------
-- Set Open Command
----------------------------------------------------------------------------------------------------
local oss = vim.loop.os_uname().sysname
rvim.open_command = oss == 'Darwin' and 'open' or 'xdg-open'

----------------------------------------------------------------------------------------------------
-- Load Modules
----------------------------------------------------------------------------------------------------
R('user.lazy'):bootstrap()
