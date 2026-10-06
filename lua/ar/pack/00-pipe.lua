local minimal = ar.plugins.minimal

if ar.get_plugin_cond('flatten.nvim', not minimal) then
  vim.pack.add(
    { 'https://github.com/willothy/flatten.nvim' },
    { confirm = false }
  )
  require('flatten').setup({
    window = { open = 'tab' },
    block_for = {
      gitcommit = true,
      gitrebase = true,
    },
    post_open = function(bufnr, winnr, _, is_blocking)
      vim.w[winnr].is_remote = true
      if is_blocking then
        vim.bo[bufnr].bufhidden = 'wipe'
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
  })
end

if ar.get_plugin_cond('unnest.nvim', not minimal) then
  vim.pack.add(
    { 'https://github.com/brianhuster/unnest.nvim' },
    { confirm = false }
  )
end
