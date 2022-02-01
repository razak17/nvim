local uv, api, fn = vim.loop, vim.api, vim.fn
local compile_path = rvim.get_runtime_dir() .. "/site/lua/_compiled_rolling.lua"
local packer = nil
local packer_ok = nil
local utils = require "user.utils"

local Plug = {}
Plug.__index = Plug

function Plug:get_plugins_list()
  local modules_dir = utils.join_paths(rvim.get_user_dir(), "modules")
  local list = {}
  local tmp = vim.split(fn.globpath(modules_dir, "*/plugins.lua"), "\n")
  for _, f in ipairs(tmp) do
    list[#list + 1] = f:sub(#modules_dir - 6, -1)
  end
  return list
end

function Plug:load_plugins()
  self.repos = {}

  local plugins_file = Plug:get_plugins_list()
  for _, m in ipairs(plugins_file) do
    local repos = require(utils.join_paths("user", m:sub(0, #m - 4)))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
end

function Plug:load_packer()
  local package_root = utils.join_paths(rvim.get_runtime_dir(), "/site/pack/")

  if not packer then
    vim.cmd "packadd packer.nvim"
    packer = require "packer"
  end

  packer_ok, packer = rvim.safe_require "packer"
  if not packer_ok then
    return
  end

  if vim.fn.isdirectory(rvim.get_runtime_dir() .. "/site/lua") ~= 1 then
    os.execute("mkdir -p " .. rvim.get_runtime_dir() .. "/site/lua")
  end

  packer.init {
    package_root = package_root,
    compile_path = compile_path,
    auto_reload_compiled = true,
    max_jobs = 50,
    git = { clone_timeout = 7000 },
    disable_commands = true,
    display = {
      open_fn = function()
        return require("packer.util").float { border = "rounded" }
      end,
    },
  }
  packer.reset()
  self:load_plugins()
  require("packer").startup(function(use)
    use { "wbthomason/packer.nvim", opt = true }
    for _, repo in ipairs(self.repos) do
      use(repo)
    end
  end)
end

function Plug:init_ensure_plugins()
  local packer_dir = rvim.get_runtime_dir() .. "/site/pack/packer/opt/packer.nvim"
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(rvim.get_runtime_dir() .. "/site/lua", 511, function()
      assert "make compile path dir failed"
    end)
    self:load_packer()
    packer.install()
  end
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      Plug:load_packer()
    end
    return packer[key]
  end,
})

function plugins.ensure_plugins()
  Plug:load_packer()
  Plug:init_ensure_plugins()

  local command = rvim.command
  command { "PlugCompile", [[lua require('user.core.plugins').compile()]] }
  command { "PlugInstall", [[lua require('user.core.plugins').install()]] }
  command { "PlugSync", [[lua require('user.core.plugins').sync()]] }
  command { "PlugClean", [[lua require('user.core.plugins').clean()]] }
  command { "PlugUpdate", [[lua require('user.core.plugins').update()]] }
  command { "PlugStatus", [[lua require('user.core.plugins').status()]] }
  command { "PlugRecompile", [[lua require('user.core.plugins').recompile()]] }
  rvim.augroup("PackerComplete", {
    {
      events = { "User" },
      targets = { "lua" },
      command = "lua require('user.core.plugins').compile()",
    },
  })

  local fmt = string.format

  command {
    "PlugCompiledEdit",
    function()
      vim.cmd(fmt("edit %s", compile_path))
    end,
  }

  command {
    "PlugCompiledDelete",
    function()
      vim.fn.delete(compile_path)
      vim.notify(fmt("Deleted %s", compile_path))
    end,
  }

  command {
    "PlugRecompile",
    function()
      vim.fn.delete(compile_path)
      vim.cmd [[:PlugCompile]]
    end,
  }

  if not vim.g.packer_compiled_loaded and vim.loop.fs_stat(compile_path) then
    vim.cmd(fmt("source %s", compile_path))
    vim.g.packer_compiled_loaded = true
  end
end

function plugins.recompile()
  Plug:load_packer()
  Plug:init_ensure_plugins()
  os.remove(compile_path)
  plugins.compile()
end

function plugins.load_compile()
  if vim.fn.filereadable(compile_path) ~= 1 then
    plugins.install()
    plugins.compile()
  else
    require "_compiled_rolling"
  end
end

return plugins
