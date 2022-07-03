local command = rvim.command
local fmt = string.format

command('Rename', [[call v:lua.require('user.utils').rename(<f-args>) ]], { nargs = 1 })

command('Todo', [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]])

command('ToggleBackground', function()
  vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'
end)

command('ReloadModule', function(args)
  require('plenary.reload').reload_module(args)
end)

-- source https://superuser.com/a/540519
-- write the visual selection to the filename passed in as a command argument then delete the
-- selection placing into the black hole register
command('MoveWrite', [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]], {
  nargs = 1,
  bang = true,
  range = true,
  complete = 'file',
})

command('MoveAppend', [[<line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _]], {
  nargs = 1,
  bang = true,
  range = true,
  complete = 'file',
})

command('AutoResize', function()
  require('user.utils').auto_resize()
end, { nargs = '?' })

command('LuaInvalidate', function(pattern)
  rvim.invalidate(pattern, true)
end, { nargs = 1 })

command('CloseOthers', function()
  vim.api.nvim_exec(
    [[
      wall
      silent execute 'bdelete ' . join(utils#buf_filt(1))
    ]],
    false
  )
end)

-- Packer
command('PlugCompile', [[lua require('user.core.plugins').compile()]])
command('PlugInstall', [[lua require('user.core.plugins').install()]])
command('PlugSync', [[lua require('user.core.plugins').sync()]])
command('PlugClean', [[lua require('user.core.plugins').clean()]])
command('PlugUpdate', [[lua require('user.core.plugins').update()]])
command('PlugStatus', [[lua require('user.core.plugins').status()]])
command('PlugInvalidate', [[lua require('user.core.plugins').invalidate()]])

command('PlugCompiledEdit', function()
  vim.cmd(fmt('edit %s', rvim.paths.packer_compiled))
end)

command('PlugCompiledDelete', function()
  require('user.core.plugins').del_compiled()
end)
