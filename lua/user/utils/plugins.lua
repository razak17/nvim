local uv, api, fn = vim.loop, vim.api, vim.fn
local fmt = string.format

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

function M:load_plugins(plugins)
  self.repos = {}

  for _, m in ipairs(plugins) do
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

function M:bootstrap_packer(packer, plugins)
  packer.init {
    package_root = join_paths(rvim.get_runtime_dir(), "/site/pack/"),
    compile_path = rvim.packer_compile_path,
    git = {
      clone_timeout = 7000,
      subcommands = {
        -- this is more efficient than what Packer is using
        fetch = "fetch --no-tags --no-recurse-submodules --update-shallow --progress",
      },
    },
    disable_commands = true,
    display = {
      open_fn = function()
        return require("packer.util").float {
          border = rvim.style.border.current,
        }
      end,
    },
  }
  packer.reset()
  M:load_plugins(plugins)
  packer.startup(function(use)
    use { "wbthomason/packer.nvim", opt = true }
    if rvim.plugins.SANE then
      for _, repo in ipairs(M.repos) do
        use(repo)
      end
    end
  end)
end

function M:goto_repo()
  local repo = fn.expand "<cfile>"
  if not repo or #vim.split(repo, "/") ~= 2 then
    return vim.cmd "norm! gf"
  end
  local url = fmt("https://www.github.com/%s", repo)
  fn.system(fn.printf(rvim.open_command .. ' "https://github.com/%s"', repo))
  vim.notify(fmt("Opening %s at %s", repo, url))
end

return M
