if not ar or ar.none then return end

local opt = vim.opt_local

opt.list = false
opt.spell = true
opt.textwidth = 78

local fn, api = vim.fn, vim.api

local config = {
  float = { enable = false },
  vertical = { size = 90 },
}

local opts = { buffer = 0 }
-- if this a vim help file create mappings to make navigation easier otherwise enable preferred editing settings
if vim.startswith(fn.expand('%'), vim.env.VIMRUNTIME) or vim.bo.readonly then
  opt.spell = false
  api.nvim_create_autocmd('BufWinEnter', {
    buffer = 0,
    callback = function(args)
      if config.float.enable then
        local source_win = api.nvim_get_current_win()
        ar.open_buf_centered_popup(args.buf)
        api.nvim_win_close(source_win, true)
        return
      end
      vim.cmd(
        string.format('wincmd L | vertical resize %d', config.vertical.size)
      )
    end,
  })
  -- https://vim.fandom.com/wiki/Learn_to_use_help
  map('n', '<CR>', '<C-]>', opts)
  map('n', '<BS>', '<C-T>', opts)
else
  map('n', '<leader>ml', 'maGovim:tw=78:ts=8:noet:ft=help:norl:<esc>`a', opts)
end

if not ar.plugins.enable or ar.plugins.minimal then return end

ar.ftplugin_conf({
  ['virt-column'] = function(col)
    if vim.bo.modifiable then col.setup_buffer({ virtcolumn = '+1' }) end
  end,
})
