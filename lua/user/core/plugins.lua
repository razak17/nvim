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
  rvim.safe_require "impatient"
  plug_utils:bootstrap_packer(packer)
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

  plugins.load_compile()

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

function plugins.del_compiled()
  if vim.fn.filereadable(rvim.packer_compile_path) ~= 1 then
    plug_utils:plug_notify "packer_compiled file does not exist"
  else
    vim.fn.delete(rvim.packer_compile_path)
    plug_utils:plug_notify "packer_compiled was deleted"
  end
end

function plugins.recompile()
  for _, m in ipairs { "ui", "editor", "tools", "lang", "completion" } do
    rvim.invalidate(fmt("user.modules.%s", m), true)
  end
  Plug:load_packer()
  plugins.ensure_installed()
  plugins.install()
  plugins.compile()
  require "_compiled_rolling"
end

rvim.augroup("PackerSetupInit", {
  {
    event = { "BufWritePost" },
    description = "Packer setup and reload",
    pattern = { "*/user/modules/**/*.lua", "*/user/config/init.lua" },
    command = function()
      plugins.recompile()
    end,
  },
  --- Open a repository from an authorname/repository string
  --- e.g. 'akinsho/example-repo'
  {
    event = { "BufEnter" },
    pattern = {
      rvim.get_user_dir() .. "modules/**/init.lua",
    },
    command = function()
      rvim.nnoremap("gf", function()
        plug_utils:goto_repo()
      end)
    end,
  },
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
