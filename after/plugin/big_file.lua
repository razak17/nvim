local enabled = ar_config.plugin.custom.big_file.enable

if not ar or ar.none or not enabled then return end

-- https://github.com/hoofcushion/hc-nvim/blob/master/lua/hc-nvim/config/init.lua?plain=1#L85
ar.bigfile = {
  size_kb = 1024,
  size_bytes = 1024 ^ 2,
  lines = 1024 * 5,
  bytes = 1024 ^ 2,
  ---@param self any
  ---@param format
  ---| "B"  # bytes
  ---| "KB" # kilobytes
  ---| "MB" # megabytes
  ---| "l"  # lines
  ---@return integer
  as = function(self, format)
    if format == 'B' then
      return self.bytes
    elseif format == 'KB' then
      return self.bytes / 1024
    elseif format == 'MB' then
      return self.bytes / (1024 ^ 2)
    elseif format == 'l' then
      return self.lines
    end
    error('unknown format at #2')
  end,
}

vim.filetype.add({
  filename = {
    ['.zsh_history'] = 'bigfile',
  },
  pattern = {
    ['.*'] = {
      function(path, buf)
        local cond = vim.bo[buf] and vim.bo[buf].filetype ~= 'bigfile' and path
        local lines = vim.api.nvim_buf_line_count(buf)
        local size = vim.fn.getfsize(path)
        if cond and lines > ar.bigfile:as('l') then return 'bigfile' end
        if cond and size > ar.bigfile:as('B') then return 'bigfile' end
        return nil
      end,
    },
  },
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = vim.api.nvim_create_augroup('big_file', { clear = true }),
  pattern = 'bigfile',
  callback = function(ev)
    if not enabled then return end
    vim.api.nvim_buf_call(ev.buf, function()
      vim.cmd([[NoMatchParen]])
      vim.wo.foldmethod = 'manual'
      vim.wo.statuscolumn = ''
      vim.wo.conceallevel = 0
      vim.schedule(
        function()
          vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ''
        end
      )
    end)
  end,
})
