local api = vim.api

return {
  {
    'subnut/nvim-ghost.nvim',
    cond = function() return vim.env.RVIM_GHOST_ENABLED == '1' end,
    lazy = false,
    init = function()
      api.nvim_create_augroup('NvimGhostUserAutocommands', { clear = false })
      api.nvim_create_autocmd('User', {
        group = 'NvimGhostUserAutocommands',
        pattern = {
          'www.reddit.com',
          'www.github.com',
          'www.protectedtext.com',
          '*github.com',
        },
        command = 'setfiletype markdown',
      })
    end,
  },
}
