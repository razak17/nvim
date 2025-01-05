local enabled = not ar.noplugin and ar.plugin.big_file.enable

if not ar or ar.none or not enabled then return end

-- https://github.com/hoofcushion/hc-nvim/blob/master/lua/hc-nvim/config/init.lua?plain=1#L85
ar.bigfile = {
  enable = true,
  size_kb = 1024,
  size_bytes = 1024 ^ 2,
  lines = 1024 * 10,
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
        return vim.bo[buf]
            and vim.bo[buf].filetype ~= 'bigfile'
            and path
            and vim.fn.getfsize(path) > ar.bigfile:as('B')
            and 'bigfile'
          or nil
      end,
    },
  },
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = vim.api.nvim_create_augroup('snacks_bigfile', { clear = true }),
  pattern = 'bigfile',
  callback = function(ev)
    if not ar.bigfile.enable then return end
    local wo = vim.wo
    vim.api.nvim_buf_call(ev.buf, function()
      vim.cmd([[NoMatchParen]])
      wo.foldmethod = 'manual'
      wo.statuscolumn = ''
      wo.conceallevel = 0
      vim.schedule(
        function()
          vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ''
        end
      )
    end)
  end,
})
