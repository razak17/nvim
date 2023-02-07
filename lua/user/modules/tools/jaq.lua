local M = {
  'is0n/jaq-nvim',
  cmd = 'Jaq',
  init = function() rvim.nnoremap('<leader>rr', ':silent only | Jaq<CR>', 'jaq: run') end,
}

function M.config()
  require('jaq-nvim').setup({
    cmds = {
      default = 'term',
      external = {
        typescript = 'ts-node %',
        javascript = 'node %',
        python = 'python %',
        rust = 'cargo run',
        cpp = 'g++ % -o $fileBase && ./$fileBase',
        go = 'go run %',
      },
    },
    behavior = { startinsert = true },
    terminal = { position = 'vert', size = 60 },
  })
  rvim.augroup('JaqConfig', {
    {
      event = { 'Filetype' },
      pattern = { 'Jaq' },
      command = function() vim.api.nvim_win_set_config(0, { border = rvim.style.current.border }) end,
    },
  })
end

return M
