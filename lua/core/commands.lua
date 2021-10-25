local M = {}

local commands = {
  { nargs = 1, "Rename", [[call v:lua.require('utils').rename(<f-args>) ]] },
  { "Todo", [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]] },
}

function M.setup()
  for _, command in ipairs(commands) do
    rvim.command(command)
  end
end

return M
