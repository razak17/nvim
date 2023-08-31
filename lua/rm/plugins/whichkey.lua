return {
  'folke/which-key.nvim',
  init = function()
    local which_key = require('which-key')

    which_key.setup({
      plugins = {
        spelling = { enabled = true },
      },
      icons = { breadcrumb = rvim.ui.icons.misc.double_chevron_right },
      window = { border = rvim.ui.current.border },
      layout = { align = 'center' },
      hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' },
      show_help = true,
    })

    which_key.register({
      [']'] = {
        name = 'next',
        ['<space>'] = 'add space below',
      },
      ['['] = {
        name = 'prev',
        ['<space>'] = 'add space above',
      },
      ['<leader>'] = {
        a = { name = 'A.I.' },
        d = { name = 'Dadbod' },
        f = { name = 'Telescope' },
        fg = { name = 'Git' },
        fv = { name = 'Vim' },
        g = { name = 'Git' },
        gb = { name = 'Blame' },
        go = { name = 'Open' },
        h = { name = 'Gitsigns' },
        i = { name = 'Toggler' },
        l = { name = 'Lsp' },
        m = { name = 'Marks' },
        n = { name = 'Notify' },
        o = { name = 'UI Toggles' },
        p = { name = 'Debugprint' },
        r = { name = 'Run' },
        s = { name = 'Splits' },
        t = { name = 'Testing' },
        tn = { name = 'Neotest' },
        to = { name = 'Overseer' },
        tv = { name = 'Vim-test' },
        v = { name = 'Vim' },
        w = { name = 'Winbar' },
      },
      ['<localleader>'] = {
        a = { name = 'Actions' },
        c = { name = 'Conceal' },
        d = { name = 'Dap' },
        db = { name = 'Breakpoint' },
        g = { name = 'Git' },
        f = { name = 'Genghis' },
        h = { name = 'Harpoon' },
        l = { name = 'Lsp' },
        n = { name = 'Neorg' },
        o = { name = 'Obsidian' },
        q = { name = 'NeoComposer' },
        r = { name = 'Rest' },
        s = { name = 'Slime' },
        t = { name = 'TODO' },
        v = { name = 'Devdocs' },
        x = { name = 'Executor' },
        z = { name = 'Zen' },
      },
    })

    which_key.register({
      l = 'lsp',
    }, { mode = 'x', prefix = '<leader>' })

    which_key.register({
      g = 'git',
    }, { mode = 'x', prefix = '<localleader>' })

    rvim.augroup('WhichKeyMode', {
      event = { 'FileType' },
      pattern = { 'which_key' },
      command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
    })
  end,
}
