local g, uv, api, fn = vim.g, vim.loop, vim.api, vim.fn
local compile_path = g.data_dir .. "/site/lua/_compiled_rolling.lua"
local packer = nil

local Plug = {}
Plug.__index = Plug

function Plug:get_plugins_list()
  local modules_dir = g.modules_dir
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
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
end

function Plug:load_packer()
  local packer_ok = nil
  local package_root = g.data_dir .. "/site/pack/"

  if not packer then
    api.nvim_command "packadd packer.nvim"
    packer = require "packer"
  end

  packer_ok, packer = pcall(require, "packer")
  if not packer_ok then
    return
  end

  if vim.fn.isdirectory(g.data_dir .. "/site/lua") ~= 1 then
    os.execute("mkdir -p " .. g.data_dir .. "/site/lua")
  end

  packer.init {
    package_root = package_root,
    compile_path = compile_path,
    auto_reload_compiled = true,
    git = { clone_timeout = 7000 },
    disable_commands = true,
    display = {
      open_fn = function()
        return require("packer.util").float { border = "single" }
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
  local packer_dir = g.data_dir .. "/site/pack/packer/opt/packer.nvim"
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(g.data_dir .. "/site/lua", 511, function()
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
  command { "PlugCompile", [[lua require('core.plugins').compile()]] }
  command { "PlugInstall", [[lua require('core.plugins').install()]] }
  command { "PlugSync", [[lua require('core.plugins').sync()]] }
  command { "PlugClean", [[lua require('core.plugins').clean()]] }
  command { "PlugUpdate", [[lua require('core.plugins').update()]] }
  command { "PlugStatus", [[lua require('core.plugins').status()]] }
  rvim.augroup("PackerComplete", {
    { events = { "User" }, targets = { "lua" }, command = "lua require('core.plugins').compile()" },
  })
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
    -- vim.notify("Packer config file not found. Run 'PlugCompile', then restart.", { timeout = 1000 })
  else
    require "_compiled_rolling"
  end
end

return plugins
