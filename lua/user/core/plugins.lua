local uv, api, fn = vim.loop, vim.api, vim.fn
local compile_path = rvim.get_runtime_dir() .. "/site/lua/_compiled_rolling.lua"
local packer = nil
local packer_ok = nil
local fmt = string.format
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

function Plug:init_ensure_installed()
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

local function plug_notify(msg)
  vim.notify(msg, nil, { title = "Packer" })
end

function plugins.ensure_installed()
  Plug:init_ensure_installed()
  Plug:load_packer()

  local command = rvim.command
  command { "PlugCompile", [[lua require('user.core.plugins').compile()]] }
  command { "PlugInstall", [[lua require('user.core.plugins').install()]] }
  command { "PlugSync", [[lua require('user.core.plugins').sync()]] }
  command { "PlugClean", [[lua require('user.core.plugins').clean()]] }
  command { "PlugUpdate", [[lua require('user.core.plugins').update()]] }
  command { "PlugStatus", [[lua require('user.core.plugins').status()]] }
  command { "PlugRecompile", [[lua require('user.core.plugins').recompile()]] }

  command {
    "PlugCompiledEdit",
    function()
      vim.cmd(fmt("edit %s", compile_path))
    end,
  }

  command {
    "PlugCompiledDelete",
    function()
      if vim.fn.filereadable(compile_path) ~= 1 then
        plug_notify "packer_compiled file does not exist"
      else
        vim.fn.delete(compile_path)
        plug_notify "packer_compiled was deleted"
      end
    end,
  }

  command {
    "PlugRecompile",
    function()
      vim.fn.delete(compile_path)
      vim.cmd [[:PlugCompile]]
      plug_notify "packer was recompiled"
    end,
  }

  if not vim.g.packer_compiled_loaded and vim.loop.fs_stat(compile_path) then
    vim.cmd(fmt("source %s", compile_path))
    vim.g.packer_compiled_loaded = true
  end
end

function plugins.recompile()
  Plug:load_packer()
  Plug:init_ensure_installed()
  os.remove(compile_path)
  plugins.compile()
end

function plugins.load_compile()
  if vim.fn.filereadable(compile_path) ~= 1 then
    plugins.install()
    plugins.compile()
    plug_notify "packer_compiled was created"
  else
    require "_compiled_rolling"
    plug_notify "packer_compiled was loaded"
  end
end

rvim.augroup("PackerSetupInit", {
  {
    event = { "BufWritePost" },
    description = 'Packer setup and reload',
    pattern = {
      utils.join_paths(rvim.get_config_dir(), "lua/core/config/init.lua"),
    },
    command = function()
      vim.cmd [[source ~/.config/rvim/lua/core/config/init.lua]]
      vim.cmd [[source ~/.config/rvim/lua/core/opts.lua]]
      vim.cmd [[source ~/.config/rvim/lua/core/binds.lua]]
      local plug = require "user.core.plugins"
      plug.ensure_plugins()
      plug.install()
      plug.load_compile()
      vim.notify("packer compiled...", { timeout = 1000 })
    end,
  },
  {
    event = { "BufEnter" },
    pattern = {
      rvim.get_user_dir() .. "modules/**/plugins.lua",
    },
    --- Open a repository from an authorname/repository string
    --- e.g. 'akinso/example-repo'
    command = function()
      rvim.nnoremap("gf", function()
        local repo = fn.expand "<cfile>"
        if not repo or #vim.split(repo, "/") ~= 2 then
          return vim.cmd "norm! gf"
        end
        local url = fmt("https://www.github.com/%s", repo)
        fn.system(fn.printf(rvim.open_command .. ' "https://github.com/%s"', repo))
        vim.notify(fmt("Opening %s at %s", repo, url))
      end)
    end,
  },
})

rvim.augroup("PackerComplete", {
  {
    event = { "User PackerCompileDone" },
    command = function()
      plug_notify "Packer compile complete"
    end,
  },
})

return plugins
