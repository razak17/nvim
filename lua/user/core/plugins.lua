local fn = vim.fn
local packer = nil
local fmt = string.format
local plug_utils = require "user.utils.plugins"

local Plug = {}
Plug.__index = Plug

function Plug:load_packer()
  if not packer then
    vim.cmd "packadd! packer.nvim"
    packer = require "packer"
  end

  if vim.fn.isdirectory(rvim.get_runtime_dir() .. "/site/lua") ~= 1 then
    os.execute("mkdir -p " .. rvim.get_runtime_dir() .. "/site/lua")
  end

  packer.init {
    package_root = join_paths(rvim.get_runtime_dir(), "/site/pack/"),
    compile_path = rvim.packer_compile_path,
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
  rvim.safe_require "impatient"
  plug_utils:load_plugins()
  packer.startup(function(use)
    use { "wbthomason/packer.nvim", opt = true }
    for _, repo in ipairs(plug_utils.repos) do
      use(repo)
    end
  end)
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      Plug:load_packer()
    end
    return packer[key]
  end,
})

function plugins.ensure_installed()
  plug_utils:init_ensure_installed()
  Plug:load_packer()

  if not vim.g.packer_compiled_loaded and vim.loop.fs_stat(rvim.packer_compile_path) then
    rvim.source(rvim.packer_compile_path)
    vim.g.packer_compiled_loaded = true
  end
end

function plugins.load_compile()
  if vim.fn.filereadable(rvim.packer_compile_path) ~= 1 then
    plugins.install()
    plugins.compile()
  end
end

function plugins.recompile()
  Plug:load_packer()
  os.remove(rvim.packer_compile_path)
  plugins.compile()
end

rvim.augroup("PackerSetupInit", {
  {
    event = { "BufWritePost" },
    description = "Packer setup and reload",
    pattern = { "*/user/modules/**/*.lua", "*/user/config/init.lua" },
    command = function()
      for _, m in ipairs { "ui", "editor", "tools", "lang", "completion" } do
        rvim.invalidate(fmt("user.modules.%s", m), true)
      end
      plugins.ensure_installed()
      plugins.install()
      plugins.compile()
      require "_compiled_rolling"
    end,
  },
  --- Open a repository from an authorname/repository string
  --- e.g. 'akinso/example-repo'
  {
    event = { "BufEnter" },
    pattern = {
      rvim.get_user_dir() .. "modules/**/init.lua",
    },
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
  -- FIXME: user autocommands are triggered multiple times
  {
    event = "User",
    pattern = "PackerCompileDone",
    description = "Inform me that packer has finished compiling",
    command = function()
      plug_utils:plug_notify "Packer compile complete"
    end,
  },
})

return plugins
