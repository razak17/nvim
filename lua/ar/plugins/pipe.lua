local minimal = ar.plugins.minimal

return {
  {
    'brianhuster/unnest.nvim',
    lazy = false,
    cond = function() return ar.get_plugin_cond('unnest.nvim', not minimal) end,
  },
  {
    'willothy/flatten.nvim',
    lazy = false,
    cond = function()
      local condition = not minimal
      return ar.get_plugin_cond('flatten.nvim', condition)
    end,
    priority = 1001,
    opts = {
      window = { open = 'tab' },
      block_for = {
        gitcommit = true,
        gitrebase = true,
      },
      post_open = function(bufnr, winnr, _, is_blocking)
        vim.w[winnr].is_remote = true
        if is_blocking then
          vim.bo.bufhidden = 'wipe'
          vim.api.nvim_create_autocmd('BufHidden', {
            desc = 'Close window when buffer is hidden',
            callback = function()
              if vim.api.nvim_win_is_valid(winnr) then
                vim.api.nvim_win_close(winnr, true)
              end
            end,
            buffer = bufnr,
            once = true,
          })
        end
      end,
    },
  },
}
