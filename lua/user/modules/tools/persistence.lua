local M = {
  'folke/persistence.nvim',
  event = 'BufReadPre', -- this will only start session saving when an actual file was opened
}

function M.init()
  rvim.nnoremap(
    '<leader>sr',
    '<cmd>lua require("persistence").load()<CR>',
    'persistence: restore for directory'
  )
  rvim.nnoremap(
    '<leader>sl',
    '<cmd>lua require("persistence").load({ last = true })<CR>',
    'persistence: restore last'
  )
end

function M.config()
  require('persistence').setup({
    dir = vim.fn.expand(rvim.get_cache_dir() .. '/sessions/'),
    options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help' },
  })
end

return M
