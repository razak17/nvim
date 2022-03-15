local uv, api, fn = vim.loop, vim.api, vim.fn

local M = {}
M.__index = M

function M:plug_notify(msg)
  vim.notify(msg, nil, { title = "Packer" })
end

function M:get_plugins_list()
  local list = {}
  local modules_dir = join_paths(rvim.get_user_dir(), "modules")
  local tmp = vim.split(fn.globpath(modules_dir, "*/init.lua"), "\n")
  for _, f in ipairs(tmp) do
    list[#list + 1] = f:sub(#modules_dir - 6, -1)
  end
  return list
end

function M:load_plugins()
  self.repos = {}

  local plugins_file = M:get_plugins_list()
  for _, m in ipairs(plugins_file) do
    local repos = require(join_paths("user", m:sub(0, #m - 4)))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
end

function M:init_ensure_installed()
  local packer_dir = rvim.get_runtime_dir() .. "/site/pack/packer/opt/packer.nvim"
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(rvim.get_runtime_dir() .. "/site/lua", 511, function()
      assert "make compile path dir failed"
    end)
    self:load_packer()
    require("packer").sync()
  end
end

return M
