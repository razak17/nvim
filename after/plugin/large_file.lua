local enabled = rvim.plugin.large_file.enable

if not rvim or rvim.none or not enabled then return end

rvim.augroup('LargeFileAutocmds', {
  event = { 'BufReadPre' },
  command = function()
    if vim.fn.getfsize(vim.fn.expand('%')) > 100 * 1024 then -- 100 KB
      rvim.large_file_opened = true

      vim.wo.wrap = false
      -- vim.o.eventignore = 'FileType'
      vim.bo.bufhidden = 'unload'
      -- vim.bo.buftype = 'nowrite'
      -- vim.bo.undolevels = -1
      vim.cmd.filetype('off')
    else
      rvim.large_file_opened = false

      -- vim.o.eventignore = nil
      vim.bo.bufhidden = ''
      -- vim.bo.buftype = ''
      -- vim.bo.undolevels = 1000
      vim.cmd.filetype('on')
    end
  end,
}, {
  event = { 'BufWinEnter' },
  command = function()
    if rvim.large_file_opened then
      -- rvim.large_file_opened = false
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

      if rvim.is_available('mini.indentscope') then
        -- vim.api.nvim_del_augroup_by_name('MiniIndentscope')
        vim.api.nvim_clear_autocmds({ group = 'MiniIndentscope' })
      end
    else
      if not vim.g.loaded_matchparen then vim.cmd('DoMatchParen') end
    end
  end,
})
