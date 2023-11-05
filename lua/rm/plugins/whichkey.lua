return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    key_labels = {
      ['<space>'] = '░',
      ['<CR>'] = '↪',
      ['<tab>'] = '→',
    },
    plugins = {
      spelling = { enabled = true },
    },
    icons = {
      breadcrumb = rvim.ui.icons.misc.double_chevron_right,
    },
    window = { border = rvim.ui.current.border },
    layout = { align = 'center' },
    hidden = {
      '<silent>',
      '<cmd>',
      '<Cmd>',
      '<CR>',
      'call',
      'lua',
      '^:',
      '^ ',
    },
    show_help = true,
  },
  init = function()
    local which_key = require('which-key')

    which_key.register({
      ['<leader>'] = {
        name = 'Advanced',
        a = 'Actions',
        b = { name = 'Comment Box' },
        l = 'LSP',
        n = { name = 'Sticky Note' },
        t = { name = 'Translate' },
      },
      a = { name = 'A.I.' },
      d = { name = 'Dadbod' },
      e = { name = 'Explorer' },
      f = { name = 'Picker' },
      fg = { name = 'Git' },
      fv = { name = 'Vim' },
      g = { name = 'Git' },
      gb = { name = 'Blame' },
      go = { name = 'Open' },
      h = { name = 'Gitsigns' },
      i = { name = 'Toggler' },
      l = { name = 'LSP' },
      m = { name = 'Marks' },
      n = { name = 'Notify' },
      o = { name = 'UI select' },
      p = { name = 'Debugprint' },
      r = { name = 'Run' },
      s = { name = 'Splits' },
      t = { name = 'Testing' },
      tc = { name = 'Coverage' },
      tn = { name = 'Neotest' },
      to = { name = 'Overseer' },
      tv = { name = 'Vim-test' },
      v = { name = 'Vim' },
      w = { name = 'Window' },
    }, { mode = 'n', prefix = '<leader>' })

    which_key.register({
      a = { name = 'Actions' },
      c = { name = 'Conceal' },
      d = { name = 'Dap' },
      db = { name = 'Breakpoint' },
      g = { name = 'Git' },
      f = { name = 'Genghis' },
      h = { name = 'Harpoon' },
      l = { name = 'LSP' },
      lr = { name = 'Rulebook' },
      m = { name = 'Markdown' },
      n = { name = 'Neorg' },
      o = { name = 'Obsidian' },
      q = { name = 'NeoComposer' },
      r = { name = 'Rest' },
      s = { name = 'Slime' },
      t = { name = 'TODO' },
      v = { name = 'Devdocs' },
      x = { name = 'Executor' },
      z = { name = 'Zen' },
    }, { mode = 'n', prefix = '<localleader>' })

    which_key.register({
      d = { name = 'Delete' },
      f = { name = 'File' },
      g = { name = 'Git' },
      go = { name = 'Open' },
      l = { name = 'LSP' },
    }, { mode = 'x', prefix = '<leader>' })

    which_key.register({
      a = { name = 'A.I.' },
      g = { name = 'Git' },
      h = { name = 'Gitsigns' },
      n = { name = 'Nag' },
      q = { name = 'NeoComposer' },
      r = { name = 'Run' },
      s = { name = 'Slime' },
    }, { mode = 'x', prefix = '<localleader>' })

    rvim.augroup('WhichKeyMode', {
      event = { 'FileType' },
      pattern = { 'which_key' },
      command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
    })
  end,
}
