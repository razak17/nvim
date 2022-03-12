local command = rvim.command

command { nargs = 1, "Rename", [[call v:lua.require('user.utils').rename(<f-args>) ]] }

command { "Todo", [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]] }

command {
  "ToggleBackground",
  function()
    vim.o.background = vim.o.background == "dark" and "light" or "dark"
  end,
}

command {
  "ReloadModule",
  function(args)
    require("plenary.reload").reload_module(args)
  end,
  nargs = 1,
}

command {
  "TabMessage",
  [[call utils#tab_message(<q-args>)]],
  nargs = "+",
  types = { "-complete=command" },
}

-- source https://superuser.com/a/540519
-- write the visual selection to the filename passed in as a command argument then delete the
-- selection placing into the black hole register
command {
  "MoveWrite",
  [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]],
  types = { "-bang", "-range", "-complete=file" },
  nargs = 1,
}

command {
  "MoveAppend",
  [[<line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _]],
  types = { "-bang", "-range", "-complete=file" },
  nargs = 1,
}

command { "AutoResize", [[call utils#auto_resize(<args>)]], { "-nargs=?" } }

command {
  "LuaInvalidate",
  function(pattern)
    rvim.invalidate(pattern, true)
  end,
  nargs = 1,
}

command {
  "LspFormat",
  function()
    vim.lsp.buf.formatting_sync(nil, 1000)
  end,
}
