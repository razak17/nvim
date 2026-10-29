local function open_pdf()
  ar.pack.load('https://github.com/saxon1964/neovim-tips')
  local pdf_path = vim.pack.get({ 'neovim-tips' })[1].path
    .. '/pdf/book/NeovimTips.pdf'
  if vim.fn.filereadable(pdf_path) == 1 then
    ar.open_media(pdf_path)
  else
    vim.notify(
      'PDF not found, generating it now. This may take a while...',
      vim.log.levels.INFO,
      { title = 'Neovim Tips' }
    )
  end
end

ar.pack.add({
  {
    src = 'https://github.com/saxon1964/neovim-tips',
    cond = function()
      return ar.get_plugin_cond('neovim-tips', not ar.plugins.minimal)
    end,
    version = vim.version.range('*'),
    cmd = {
      'NeovimTips',
      'NeovimTipsAdd',
      'NeovimTipsEdit',
      'NeovimTipsRandom',
      'NeovimTipsPdf',
    },
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
    dependencies = {
      { src = 'https://github.com/MunifTanjim/nui.nvim' },
    },
    setup = function()
      require('neovim_tips').setup({
        user_file = vim.fn.stdpath('config') .. '/tips/user_tips.md',
        user_tip_prefix = '[User] ',
        -- 0 = off, 1 = once per day, 2 = every startup
        daily_tip = 2,
        bookmark_symbol = '🌟 ',
      })
    end,
  },
})
