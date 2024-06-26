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
        f = 'Snap',
        j = {
          name = 'jSdoc Switch',
          d = 'doc switch',
        },
        l = 'LSP',
        n = { name = 'Sticky Note' },
        r = { name = 'Run' },
        t = { name = 'Translate' },
      },
      [','] = {
        name = 'Advanced',
        f = { name = 'Genghis' },
      },
      a = {
        name = 'A.I.',
        c = {
          name = 'CopilotChat',
        },
      },
      d = { name = 'Dadbod' },
      e = { name = 'Explorer' },
      f = { name = 'Telescope' },
      F = { name = 'Picker (Current Dir)' },
      fg = { name = 'Git' },
      fv = { name = 'Vim' },
      g = { name = 'Git' },
      gb = { name = 'Blame' },
      go = { name = 'Open' },
      gi = { name = 'Issues' },
      gs = { name = 'Stash' },
      gy = { name = 'Yank' },
      h = { name = 'Gitsigns' },
      i = { name = 'Toggler' },
      l = { name = 'LSP' },
      m = { name = 'Marks' },
      n = { name = 'Notify' },
      o = { name = 'UI select' },
      p = {
        name = 'Debugprint',
        l = { name = 'Chainsaw' },
      },
      r = { name = 'Run' },
      s = { name = 'Splits' },
      t = { name = 'Testing' },
      u = { name = 'URL' },
      tc = { name = 'Coverage' },
      tn = { name = 'Neotest' },
      to = { name = 'Overseer' },
      tv = { name = 'Vim-test' },
      v = { name = 'Vim' },
      w = { name = 'Window' },
      wm = { name = 'Maximizer' },
    }, { mode = 'n', prefix = '<leader>' })

    which_key.register({
      a = { name = 'Actions' },
      A = { name = 'Animations' },
      c = { name = 'Conceal' },
      d = { name = 'Dap' },
      db = { name = 'Breakpoint' },
      f = { name = 'Picker' },
      fg = { name = 'Git' },
      fv = { name = 'Vim' },
      g = { name = 'Git' },
      go = { name = 'Open' },
      gy = { name = 'Yank' },
      h = { name = 'Harpoon' },
      l = { name = 'LSP' },
      lc = { name = 'Call Hierarchy' },
      lr = { name = 'Rulebook' },
      m = { name = 'Markdown' },
      n = { name = 'Neorg' },
      o = { name = 'Obsidian' },
      p = { name = 'Null Pointer' },
      q = { name = 'NeoComposer' },
      r = { name = 'Rest' },
      s = { name = 'Strict' },
      t = { name = 'TODO' },
      v = { name = 'Devdocs' },
      x = { name = 'Executor' },
      y = { name = 'Yanky' },
      z = { name = 'Zen' },
    }, { mode = 'n', prefix = '<localleader>' })

    which_key.register({
      ['<leader>'] = { name = 'Advanced' },
      a = { name = 'Actions' },
      d = { name = 'Delete' },
      f = { name = 'File' },
      g = { name = 'Git' },
      go = { name = 'Open' },
      h = { name = 'Hunk' },
      l = { name = 'LSP' },
      r = { name = 'Run' },
    }, { mode = 'x', prefix = '<leader>' })

    which_key.register({
      a = { name = 'A.I.' },
      g = { name = 'Git' },
      h = { name = 'Gitsigns' },
      l = { name = 'LSP' },
      n = { name = 'Nag' },
      p = { name = 'Share' },
      q = { name = 'NeoComposer' },
      S = { name = 'Sort' },
      y = { name = 'Yanky' },
    }, { mode = 'x', prefix = '<localleader>' })

    rvim.augroup('WhichKeyMode', {
      event = { 'FileType' },
      pattern = { 'which_key' },
      command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
    })
  end,
}
