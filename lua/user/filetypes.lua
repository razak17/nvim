if not rvim then return end

for _, filetype in ipairs(rvim.filetypes) do
  rvim.augroup('LoadAfterFtplugin', {
    {
      event = { 'BufEnter' },
      pattern = { '*' },
      command = function()
        if vim.bo.filetype == filetype then require_clean('user.core.filetypes.' .. filetype) end
      end,
    },
  })
end
