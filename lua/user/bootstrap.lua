if not rvim then return end

local g, rtp = vim.g, vim.opt.rtp

----------------------------------------------------------------------------------------------------
-- Set leader keys
----------------------------------------------------------------------------------------------------
g.mapleader = ' '
g.maplocalleader = ','

----------------------------------------------------------------------------------------------------
-- Set Providers
----------------------------------------------------------------------------------------------------
g.python3_host_prog = join_paths(rvim.get_cache_dir(), 'venv', 'neovim', 'bin', 'python3')
for _, v in pairs({ 'python', 'ruby', 'perl' }) do
  g['loaded_' .. v .. '_provider'] = 0
end

----------------------------------------------------------------------------------------------------
-- Set Open Command
----------------------------------------------------------------------------------------------------
g.os = vim.loop.os_uname().sysname
rvim.open_command = g.os == 'Darwin' and 'open' or 'xdg-open'

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
R('user.settings')
R('user.highlights')
R('user.ui')
R('user.lazy'):bootstrap() -- Lazy has to be sourced last. Depends on modules above
