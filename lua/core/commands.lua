local M = {}
-- [[command! -complete=file -nargs=1 Remove :echo 'Remove: '.'<f-args>'.' '.(delete(<f-args>) == 0 ? 'SUCCEEDED' : 'FAILED')]]
local commands = {
  { nargs = 1, "Rename", [[call v:lua.require('utils').rename(<f-args>) ]] },
  { "Todo", [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]] },
}

function M.setup()
  for _, command in ipairs(commands) do
    rvim.command(command)
  end
  -- vim.cmd "command! -complete=file -nargs=1 Remove :echo 'Remove: '.'<f-args>'.' '.(delete(<f-args>) == 0 ? 'SUCCEEDED' : 'FAILED')"
end

return M
