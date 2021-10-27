local cmd = vim.cmd

-- TODO: handle this better
if os.getenv "RVIM_CONFIG_DIR" and os.getenv "RVIM_RUNTIME_DIR" then
  local path_sep = vim.loop.os_uname().version:match "Windows" and "\\" or "/"
  vim.opt.rtp:append(os.getenv "RVIM_CONFIG_DIR")
  vim.opt.rtp:append(os.getenv "RVIM_RUNTIME_DIR" .. path_sep .. "site")
end

-- TODO: Whatever this is
cmd [[let &packpath = &runtimepath]]
cmd [[syntax off]]
cmd [[filetype off]]

-- Load Modules
require("config"):load()
