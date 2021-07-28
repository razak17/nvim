local uv, api, fn = vim.loop, vim.api, vim.fn
local packer_compiled = rvim.__data_dir .. "/site/packer_compiled.vim"
local install_path = rvim.__data_dir .. "/site/pack/"
local compile_to_lua = rvim.__data_dir .. "/site/lua/_compiled_main.lua"
local packer = nil
local packer_ok = nil
local command = rvim.command

local Plug = {}
Plug.__index = Plug

function Plug:get_plugins_list()
  local modules_dir = rvim.__modules_dir
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
      self.repos[#self.repos + 1] = vim.tbl_extend("force", {repo}, conf)
    end
  end
end

function Plug:load_packer()
  if not packer then
    api.nvim_command("packadd packer.nvim")
    packer = require("packer")
  end

  packer_ok, packer = pcall(require, "packer")
  if not packer_ok then
    return
  end

  packer.init({
    package_root = install_path,
    compile_path = packer_compiled,
    auto_reload_compiled = true,
    git = {clone_timeout = 7000},
    disable_commands = true,
    display = {
      open_fn = function()
        return require("packer.util").float({border = "single"})
      end,
    },
  })
  packer.reset()
  self:load_plugins()
  require("packer").startup(function(use)
    use({"wbthomason/packer.nvim", opt = true})
    for _, repo in ipairs(self.repos) do
      use(repo)
    end
  end)
end

function Plug:init_ensure_plugins()
  local packer_dir = rvim.__data_dir .. "/site/pack/packer/opt/packer.nvim"
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(rvim.__data_dir .. "/site/lua", 511, function()
      assert("make compile path dir faield")
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
  Plug:init_ensure_plugins()
end

function plugins.convert_compile_file()
  local lines = {}
  local lnum = 1
  lines[#lines + 1] = "vim.cmd [[packadd packer.nvim]]\n"

  for line in io.lines(packer_compiled) do
    lnum = lnum + 1
    if lnum > 15 then
      lines[#lines + 1] = line .. "\n"
      if line == "END" then
        break
      end
    end
  end
  table.remove(lines, #lines)

  if vim.fn.isdirectory(rvim.__data_dir .. "/site/lua") ~= 1 then
    os.execute("mkdir -p " .. rvim.__data_dir .. "/site/lua")
  end

  if vim.fn.filereadable(compile_to_lua) == 1 then
    os.remove(compile_to_lua)
  end

  local file = io.open(compile_to_lua, "w")
  for _, line in ipairs(lines) do
    file:write(line)
  end
  file:close()

  os.remove(packer_compiled)
end

function plugins.magic_compile()
  plugins.compile()
  plugins.convert_compile_file()
end

function plugins.auto_compile()
  local file = vim.fn.expand("%:p")
  if file:match(rvim.__modules_dir) then
    plugins.clean()
    plugins.compile()
    plugins.convert_compile_file()
  end
end

function plugins.load_compile()
  if vim.fn.filereadable(compile_to_lua) == 1 then
    require("_mcompiled")
  else
    assert("Missing packer compile file Run PackerCompile Or PackerInstall to fix")
    plugins.install()
    plugins.magic_compile()
  end
  command({"PlugCompile", [[call v:lua.require('core.plug').magic_compile()]]})
  command({"PlugInstall", [[lua require('core.plug').install()]]})
  command({"PlugSync", [[lua require('core.plug').sync()]]})
  command({"PlugClean", [[lua require('core.plug').clean()]]})
  command({"PlugUpdate", [[lua require('core.plug').update()]]})
  command({"PlugStatus", [[lua require('core.plug').status()]]})
  rvim.augroup("PackerComplete", {
    {events = {"User"}, targets = {"lua"}, command = "lua require('core.plug').magic_compile()"},
  })
end

return plugins
