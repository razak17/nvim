local largefile_opened = false

rvim.augroup('LargeFileAutocmds', {
  event = { 'BufReadPre' },
  command = function()
    if vim.fn.getfsize(vim.fn.expand('%')) > 100 * 1024 then -- 100 KB
      largefile_opened = true

      vim.wo.wrap = false
      -- vim.o.eventignore = 'FileType'
      vim.bo.bufhidden = 'unload'
      -- vim.bo.buftype = 'nowrite'
      vim.bo.undolevels = -1
      vim.cmd.filetype('off')
    else
      vim.o.eventignore = nil
      vim.bo.bufhidden = ''
      vim.bo.buftype = ''
      vim.bo.undolevels = 1000
      vim.cmd.filetype('on')
    end
  end,
}, {
  event = { 'BufWinEnter' },
  command = function()
    if largefile_opened then
      largefile_opened = false
      vim.o.eventignore = nil
    end
  end,
}, {
  event = { 'BufEnter' },
  command = function()
    local byte_size = vim.api.nvim_buf_get_offset(
      vim.api.nvim_get_current_buf(),
      vim.api.nvim_buf_line_count(vim.api.nvim_get_current_buf())
    )
    if byte_size > 100 * 1024 then
      if vim.g.loaded_matchparen then vim.cmd('NoMatchParen') end
    else
      if not vim.g.loaded_matchparen then vim.cmd('DoMatchParen') end
    end
  end,
})
