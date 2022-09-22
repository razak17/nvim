local command = rvim.command

command('Rename', [[call v:lua.require('user.utils').rename(<f-args>) ]], { nargs = 1 })

command('Todo', [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]])

command('ToggleBackground', function() vim.o.background = vim.o.background == 'dark' and 'light' or 'dark' end)

command('ReloadModule', function(args) require('plenary.reload').reload_module(args) end)

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

command('AutoResize', function() require('user.utils').auto_resize() end, { nargs = '?' })

command('LuaInvalidate', function(pattern) rvim.invalidate(pattern, true) end, { nargs = 1 })

command(
  'CloseOthers',
  function()
    vim.api.nvim_exec(
      [[
      wall
      silent execute 'bdelete ' . join(utils#buf_filt(1))
    ]],
      false
    )
  end
)

-- Packer
local cmds = {
  'Compile',
  'Install',
  'Update',
  'Sync',
  'Clean',
  'Status',
  'Invalidate',
  'Reload',
  'Recompile',
  'Delete',
}
for _, cmd in ipairs(cmds) do
  command('Packer' .. cmd, function() require('user.core.plugins')[vim.fn.tolower(cmd)]() end)
end
command('PackerCompiledEdit', function() vim.cmd.edit(rvim.paths.packer_compiled) end)
