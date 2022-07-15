local runtime_dir = rvim.get_runtime_dir()
local config_dir = rvim.get_config_dir()

if vim.env.RVIM_RUNTIME_DIR then
  vim.opt.rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site'))
  vim.opt.rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site', 'after'))
  vim.opt.rtp:prepend(join_paths(runtime_dir, 'site'))
  vim.opt.rtp:append(join_paths(runtime_dir, 'site', 'after'))

  vim.opt.rtp:remove(vim.call('stdpath', 'config'))
  vim.opt.rtp:remove(join_paths(vim.call('stdpath', 'config'), 'after'))
  vim.opt.rtp:prepend(config_dir)
  vim.opt.rtp:append(join_paths(config_dir, 'after'))
end

vim.cmd([[let &packpath = &runtimepath]])

R('user.config.defaults')
R('user.config.style')
R('user.lsp.config')
