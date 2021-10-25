local M = {}

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
