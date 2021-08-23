local M = {}

local commands = {
  { nargs = 1, "Rename", [[call v:lua.require('utils').rename(<f-args>) ]] },
  {
    "ToggleBackground",
    function()
      vim.o.background = vim.o.background == "dark" and "light" or "dark"
    end,
  },
  { "Todo", [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]] },
  { "AutoResize", [[call utils#auto_resize(<args>)]], { "-nargs=?" } },
}

function M.setup()
  for _, command in ipairs(commands) do
    rvim.command(command)
  end
end

return M
