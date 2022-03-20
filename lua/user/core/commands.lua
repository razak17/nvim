local command = rvim.command

command("Rename", [[call v:lua.require('user.utils').rename(<f-args>) ]], { nargs = 1 })

command("Todo", [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]])

command("ToggleBackground", function()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
end)

command("ReloadModule", function(args)
  require("plenary.reload").reload_module(args)
end)

command("TabMessage", [[call utils#tab_message(<q-args>)]], {
  nargs = "+",
  -- types = { "-complete=command" },
})
-- source https://superuser.com/a/540519
-- write the visual selection to the filename passed in as a command argument then delete the
-- selection placing into the black hole register
command("MoveWrite", [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]], {
  nargs = 1,
  bang = true,
  range = true,
  complete = "file",
})

command("MoveAppend", [[<line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _]], {
  nargs = 1,
  bang = true,
  range = true,
  complete = "file",
})

-- command("AutoResize", [[call utils#auto_resize(<args>)]], { "-nargs=?" })

command("LuaInvalidate", function(pattern)
  rvim.invalidate(pattern, true)
end, { nargs = 1 })

command("LspFormat", function()
  vim.lsp.buf.formatting_sync(nil, 1000)
end)

-- Packer
local utils = require "user.utils.plugins"
local fmt = string.format

command("PlugCompile", [[lua require('user.core.plugins').compile()]])
command("PlugInstall", [[lua require('user.core.plugins').install()]])
command("PlugSync", [[lua require('user.core.plugins').sync()]])
command("PlugClean", [[lua require('user.core.plugins').clean()]])
command("PlugUpdate", [[lua require('user.core.plugins').update()]])
command("PlugStatus", [[lua require('user.core.plugins').status()]])
command("PlugRecompile", [[lua require('user.core.plugins').recompile()]])

command("PlugCompiledEdit", function()
  vim.cmd(fmt("edit %s", rvim.packer_compile_path))
end)

command("PlugCompiledDelete", function()
  if vim.fn.filereadable(rvim.packer_compile_path) ~= 1 then
    utils:plug_notify "packer_compiled file does not exist"
  else
    vim.fn.delete(rvim.packer_compile_path)
    utils:plug_notify "packer_compiled was deleted"
  end
end)

command("PlugRecompile", function()
  vim.fn.delete(rvim.packer_compile_path)
  vim.cmd [[:PlugCompile]]
  utils:plug_notify "packer was recompiled"
end)
