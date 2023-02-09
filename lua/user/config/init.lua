if not rvim then return end

local g = vim.g

----------------------------------------------------------------------------------------------------
-- Set leader keys
----------------------------------------------------------------------------------------------------
g.mapleader = (rvim.keys.leader == 'space' and ' ') or rvim.keys.leader
g.maplocalleader = (rvim.keys.localleader == 'space' and ' ') or rvim.keys.localleader

----------------------------------------------------------------------------------------------------
-- Set Providers & Disable Builtins
----------------------------------------------------------------------------------------------------
g.python3_host_prog = rvim.path.python3
for _, v in pairs(rvim.util.disabled_providers) do
  g['loaded_' .. v .. '_provider'] = 0
end
for _, plugin in pairs(rvim.util.disabled_builtins) do
  g['loaded_' .. plugin] = 1
end

----------------------------------------------------------------------------------------------------
-- Set Open Command
----------------------------------------------------------------------------------------------------
g.os = vim.loop.os_uname().sysname
rvim.open_command = g.os == 'Darwin' and 'open' or 'xdg-open'

----------------------------------------------------------------------------------------------------
-- Load Modules
----------------------------------------------------------------------------------------------------
R('user.lazy'):bootstrap()
