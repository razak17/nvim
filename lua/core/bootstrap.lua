local M = {}

local uv = vim.loop
local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
  local result = table.concat({ ... }, path_sep)
  return result
end

---Get the full path to `$RVIM_RUNTIME_DIR`
---@return string
function _G.get_runtime_dir()
  local rvim_runtime_dir = os.getenv "RVIM_RUNTIME_DIR"
  if not rvim_runtime_dir then
    -- when nvim is used directly
    return vim.fn.stdpath "data"
  end
  return rvim_runtime_dir
end

---Get the full path to `$RVIM_CONFIG_DIR`
---@return string
function _G.get_config_dir()
  local rvim_config_dir = os.getenv "RVIM_CONFIG_DIR"
  if not rvim_config_dir then
    return vim.fn.stdpath "config"
  end
  return rvim_config_dir
end

function M:init()
  local home_dir = vim.loop.os_homedir()

  vim.opt.rtp:append(home_dir .. "/.local/share/rvim/site")

  vim.opt.rtp:remove(home_dir .. "/.config/nvim")
  vim.opt.rtp:remove(home_dir .. "/.config/rvim/plugin")
  vim.opt.rtp:remove(home_dir .. "/.config/nvim/after")
  vim.opt.rtp:append(home_dir .. "/.config/rvim")
  vim.opt.rtp:append(home_dir .. "/.config/rvim/after")

  vim.opt.rtp:remove(home_dir .. "/.local/share/nvim/site")
  vim.opt.rtp:remove(home_dir .. "/.local/share/nvim/site/after")
  vim.opt.rtp:append(home_dir .. "/.local/share/rvim/site")
  vim.opt.rtp:append(home_dir .. "/.local/share/rvim/site/after")
end

return M
