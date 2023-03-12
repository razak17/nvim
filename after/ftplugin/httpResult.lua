vim.api.nvim_create_autocmd('BufWinEnter', {
  buffer = 0,
  command = 'wincmd L | vertical resize 80',
})
