local fn = vim.fn
local minimal = ar.plugins.minimal

local pdf_path = fn.stdpath('data')
  .. '/lazy/neovim-tips/pdf/book/NeovimTips.pdf'

local function open_pdf()
  if fn.filereadable(pdf_path) == 1 then
    ar.open_media(pdf_path)
  else
    vim.notify(
      'PDF not found, generating it now. This may take a while...',
      vim.log.levels.INFO,
      { title = 'Neovim Tips' }
    )
  end
end

return {
  {
    'saxon1964/neovim-tips',
    cond = function() return ar.get_plugin_cond('neovim-tips', not minimal) end,
    event = { 'VeryLazy' },
    version = '*', -- Only update on tagged releases
    -- stylua: ignore
    cmd = { 'NeovimTips', 'NeovimTipsAdd', 'NeovimTipsEdit', 'NeovimTipsRandom',
      'NeovimTipsPdf' },
    init = function()
      vim.g.whichkey_add_spec({ '<leader>nt', group = 'Neovim Tips' })
    end,
    keys = {
      { '<leader>nto', '<Cmd>NeovimTips<CR>', desc = 'neovim tips' },
      { '<leader>nte', '<Cmd>NeovimTipsEdit<CR>', desc = 'edit neovim tips' },
      { '<leader>nta', '<Cmd>NeovimTipsAdd<CR>', desc = 'add neovim tip' },
      { '<leader>ntr', '<Cmd>NeovimTipsRandom<CR>', desc = 'show random tip' },
      { '<leader>ntp', open_pdf, desc = 'open neovim tips pdf' },
    },
    opts = {
      user_file = fn.stdpath('config') .. '/neovim_tips/user_tips.md',
      user_tip_prefix = '[User] ',
      -- 0 = off, 1 = once per day, 2 = every startup
      daily_tip = 2,
      bookmark_symbol = '🌟 ',
    },
    dependencies = { 'MunifTanjim/nui.nvim' },
  },
}
