if not rvim then return end

----------------------------------------------------------------------------------------------------
-- Set leader keys
----------------------------------------------------------------------------------------------------
if rvim.ui.line_wrap_cursor_movement then vim.opt.whichwrap:append('<,>,[,],h,l,~') end
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
-- Load Modules
----------------------------------------------------------------------------------------------------
-- NOTE: order matters
R('user.core.lazy').ensure_plugins()
R('user.core.highlights')
