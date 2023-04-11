if not rvim then return end

local api, cmd = vim.api, vim.cmd

rvim.augroup('UnusedBuffers', {
  event = 'BufRead',
  command = function(args)
    api.nvim_create_autocmd({ 'InsertEnter', 'BufModifiedSet' }, {
      buffer = args.buf,
      once = true,
      callback = function(a) vim.b[a.buf].bufpersist = true end,
    })
  end,
})

local function close_buffers(bufs)
  cmd.wall()
  rvim.foreach(function(buf) api.nvim_buf_delete(buf, { force = true }) end, bufs)
end

rvim.command('CloseUnusedBuffers', function()
  local curbuf = api.nvim_get_current_buf()
  local bufs = vim.tbl_filter(
    function(buf) return vim.bo[buf].buflisted and buf ~= curbuf and not vim.b[buf].bufpersist end,
    api.nvim_list_bufs()
  )
  if #bufs > 0 then close_buffers(bufs) end
end)

rvim.command('CloseAllBuffers', function()
  local bufs = api.nvim_list_bufs()
  if #bufs > 0 then close_buffers(bufs) end
end)

map('n', 'gbc', '<Cmd>CloseUnusedBuffers<CR>', { silent = true, desc = 'Close unused buffers' })
map('n', 'gba', '<Cmd>CloseAllBuffers<CR>', { silent = true, desc = 'Close all buffers' })
