local api = vim.api

local function command(name, exec)
  api.nvim_command("command! " .. name .. " " .. exec)
end

-------------------- COMMANDS ------------------------------

--- Only install missing plugins
command(
  "PlugInstall",
  "execute 'luafile ' . stdpath('config') . '/lua/plugins.lua' | packadd packer.nvim | lua require('plugins').install()"
)
--- Update and install plugins
command(
  "PlugUpdate",
  "execute 'luafile ' . stdpath('config') . '/lua/plugins.lua' | packadd packer.nvim | lua require('plugins').update()"
)
--- Remove any disabled or unused plugins
command(
  "PlugClean",
  "execute 'luafile ' . stdpath('config') . '/lua/plugins.lua' | packadd packer.nvim | lua require('plugins').clean()"
)
--- Recompiles lazy loaded plugins
command(
  "PlugCompile",
  "execute 'luafile ' . stdpath('config') . '/lua/plugins.lua' | packadd packer.nvim | lua require('plugins').compile()"
)
--- Performs `PlugClean` and then `PlugUpdate`
command(
  "PlugSync",
  "execute 'luafile ' . stdpath('config') . '/lua/plugins.lua' | packadd packer.nvim | lua require('plugins').sync()"
)
