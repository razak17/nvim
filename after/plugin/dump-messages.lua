local enabled = ar.config.plugin.custom.dump_messages.enable

if not ar or ar.none or not enabled then return end

-- Dump messages in buffer
-- https://www.reddit.com/r/neovim/comments/1dyngff/a_lua_script_to_dump_messages_to_a_buffer_for/
local function dump()
  local tmpname = vim.fn.tempname()
  vim.g._messages = ''
  vim.schedule(function()
    vim.cmd('redir => g:_messages')
    vim.cmd('silent! messages')
    vim.cmd('redir END')
    local file = io.open(tmpname, 'w')
    if file then
      file:write(vim.trim(vim.g._messages))
      file:close()
    end
    vim.cmd('vsp ' .. tmpname)
    vim.cmd('wincmd l')
    vim.g._messages = nil
  end)
end

map('n', '<localleader>mm', dump, { desc = 'dump messages' })
