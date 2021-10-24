local g, uv, api, fn = vim.g, vim.loop, vim.api, vim.fn
local install_path = g.data_dir .. "/site/pack/"
local packer_compiled = g.data_dir .. "/site/packer_compiled.vim"
local compile_to_lua = g.data_dir .. "/site/lua/_compiled_rolling.lua"
local packer = nil
local packer_ok = nil
local command = rvim.command

local plugin_loader = {}
plugin_loader.__index = plugin_loader

function plugin_loader:get_plugins_list()
  local modules_dir = g.modules_dir
  local list = {}
  local tmp = vim.split(fn.globpath(modules_dir, "*/plugins.lua"), "\n")
  for _, f in ipairs(tmp) do
    list[#list + 1] = f:sub(#modules_dir - 6, -1)
  end
  return list
end

function plugin_loader:load_plugins()
  self.repos = {}

  local plugins_file = plugin_loader:get_plugins_list()
  for _, m in ipairs(plugins_file) do
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
end

function plugin_loader:load_packer()
  if not packer then
    api.nvim_command "packadd packer.nvim"
    packer = require "packer"
  end

  packer_ok, packer = pcall(require, "packer")
  if not packer_ok then
    return


  packer.init {
    package_root = install_path,
    compile_path = compile_to_lua,
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

function plugin_loader:init_ensure_plugins()
  local packer_dir = g.data_dir .. "/site/pack/packer/opt/packer.nvim"
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(g.data_dir .. "/site/lua", 511, function()
      assert "make compile path dir faield"
    end)
    self:load_packer()
    packer.install()
  end
end

local M = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      plugin_loader:load_packer()
      return packer[key]
    end
    return packer[key]
  end,
})

function M.ensure_plugins()
  plugin_loader.init_ensure_plugins()
end

function M.convert_compile_file()
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

  if vim.fn.isdirectory(g.data_dir .. "/site/lua") ~= 1 then
    os.execute("mkdir -p " .. g.data_dir .. "/site/lua")
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

function M.magic_compile()
  M.compile()
  M.convert_compile_file()
end

function M.auto_compile()
  local file = vim.fn.expand "%:p"
  if file:match(rvim.__modules_dir) then
    M.clean()
    M.compile()
    M.convert_compile_file()
  end
end

function M.commands()
  command { "PlugCompile", [[call v:lua.require('core.plugin-loader').magic_compile()]] }
  command { "PlugInstall", [[lua require('core.plugin-loader').install()]] }
  command { "PlugSync", [[lua require('core.plugin-loader').sync()]] }
  command { "PlugClean", [[lua require('core.plugin-loader').clean()]] }
  command { "PlugUpdate", [[lua require('core.plugin-loader').update()]] }
  command { "PlugStatus", [[lua require('core.plugin-loader').status()]] }
  rvim.augroup("PackerComplete", {
    { events = { "User" }, targets = { "lua" }, command = "lua require('core.plugins').magic_compile()" },
  })
end

function M.load_compile()
  if vim.fn.filereadable(compile_to_lua) == 1 then
    require "_compiled_rolling"
  else
    assert "Missing packer compile file Run PackerCompile Or PackerInstall to fix"
    M.install()
    M.magic_compile()
  end
end

function M:init()
  M.commands()
  M.load_compile()
  M.ensure_plugins()

  local nnoremap = rvim.nnoremap
  nnoremap("<Leader>Ec", ":PlugCompile<CR>")
  nnoremap("<Leader>EC", ":PlugClean<CR>")
  nnoremap("<Leader>Ei", ":PlugInstall<CR>")
  nnoremap("<Leader>Es", ":PlugSync<CR>")
  nnoremap("<Leader>ES", ":PlugStatus<CR>")
  nnoremap("<Leader>Ee", ":PlugUpdate<CR>")
end

return M
