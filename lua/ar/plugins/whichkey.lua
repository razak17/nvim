return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  -- TODO:align center is broken
  opts = {
    icons = {
      rules = false,
      keys = { CR = '↪', TAB = '→', Space = '󱁐 ' },
    },
    win = {
      height = { min = 10, max = 25 },
      border = ar.ui.current.border,
      wo = {
        winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      },
    },
    layout = { align = 'center' },
    spec = {
      {
        mode = { 'n' },
        { '<leader>A', group = 'Animations' },
        { '<leader>F', group = 'Picker (Current Dir)' },
        { '<leader>a', group = 'A.I.' },
        { '<leader>ac', group = 'CopilotChat' },
        { '<leader>e', group = 'Explorer' },
        { '<leader>f', group = 'Telescope' },
        { '<leader>fg', group = 'Git' },
        { '<leader>fv', group = 'Vim' },
        { '<leader>g', group = 'Git' },
        { '<leader>gb', group = 'Blame' },
        { '<leader>go', group = 'Open' },
        { '<leader>gs', group = 'Stash' },
        { '<leader>gy', group = 'Yank' },
        { '<leader>h', group = 'Gitsigns' },
        { '<leader>i', group = 'Toggler' },
        { '<leader>l', group = 'LSP' },
        { '<leader>m', group = 'Marks' },
        { '<leader>n', group = 'Notify' },
        { '<leader>o', group = 'UI select' },
        { '<leader>p', group = 'Debugprint' },
        { '<leader>pl', group = 'Chainsaw' },
        { '<leader>r', group = 'Run' },
        { '<leader>s', group = 'Splits' },
        { '<leader>t', group = 'Testing' },
        { '<leader>tc', group = 'Coverage' },
        { '<leader>tn', group = 'Neotest' },
        { '<leader>to', group = 'Overseer' },
        { '<leader>tv', group = 'Vim-test' },
        { '<leader>u', group = 'URL' },
        { '<leader>v', group = 'Vim' },
        { '<leader>w', group = 'Window' },
        { '<leader>wm', group = 'Maximizer' },
        { '<localleader>a', group = 'Actions' },
        { '<localleader>b', group = 'Buffer' },
        { '<localleader>c', group = 'Conceal' },
        { '<localleader>d', group = 'Dap' },
        { '<localleader>db', group = 'Breakpoint' },
        { '<localleader>f', group = 'Picker' },
        { '<localleader>fg', group = 'Git' },
        { '<localleader>fv', group = 'Vim' },
        { '<localleader>g', group = 'Git' },
        { '<localleader>go', group = 'Open' },
        { '<localleader>gy', group = 'Yank' },
        { '<localleader>h', group = 'Harpoon' },
        { '<localleader>l', group = 'LSP' },
        { '<localleader>lc', group = 'Call Hierarchy' },
        { '<localleader>lr', group = 'Rulebook' },
        { '<localleader>m', group = 'Markdown' },
        { '<localleader>n', group = 'Neorg' },
        { '<localleader>o', group = 'Obsidian' },
        { '<localleader>p', group = 'Null Pointer' },
        { '<localleader>q', group = 'NeoComposer' },
        { '<localleader>r', group = 'Monorepo' },
        { '<localleader>s', group = 'Strict' },
        { '<localleader>t', group = 'TODO' },
        { '<localleader>v', group = 'Devdocs' },
        { '<localleader>x', group = 'Trouble' },
        { '<localleader>y', group = 'Yanky' },
        { '<localleader>z', group = 'Zen' },
        { '<leader><leader>', group = 'Advanced' },
        { '<leader><leader>a', desc = 'Actions' },
        { '<leader><leader>b', group = 'Comment Box' },
        { '<leader><leader>d', group = 'Dadbod' },
        { '<leader><leader>f', group = 'Snap' },
        { '<leader><leader>g', group = 'Git' },
        { '<leader><leader>gh', group = 'History' },
        { '<leader><leader>gi', group = 'Issues' },
        { '<leader><leader>go', group = 'Open' },
        { '<leader><leader>gs', group = 'Stash' },
        { '<leader><leader>j', group = 'jSdoc Switch' },
        { '<leader><leader>jd', desc = 'doc switch' },
        { '<leader><leader>l', desc = 'LSP' },
        { '<leader><leader>n', group = 'Sticky Note' },
        { '<leader><leader>t', group = 'Translate' },
        { '<leader><leader>x', group = 'Executor' },
        { '<leader>,', group = 'Advanced' },
        { '<leader>,f', group = 'Genghis' },
        { '<leader>,r', group = 'Rustlings' },
      },
      {
        mode = { 'x' },
        { '<leader><leader>', group = 'Advanced' },
        { '<leader>a', group = 'Actions' },
        { '<leader>d', group = 'Delete' },
        { '<leader>f', group = 'File' },
        { '<leader>g', group = 'Git' },
        { '<leader>go', group = 'Open' },
        { '<leader>h', group = 'Hunk' },
        { '<leader>l', group = 'LSP' },
        { '<leader>r', group = 'Run' },
        { '<localleader>S', group = 'Sort' },
        { '<localleader>a', group = 'A.I.' },
        { '<localleader>g', group = 'Git' },
        { '<localleader>h', group = 'Gitsigns' },
        { '<localleader>l', group = 'LSP' },
        { '<localleader>n', group = 'Nag' },
        { '<localleader>p', group = 'Share' },
        { '<localleader>q', group = 'NeoComposer' },
        { '<localleader>y', group = 'Yanky' },
      },
    },
  },
  init = function()
    ar.augroup('WhichKeyMode', {
      event = { 'FileType' },
      pattern = { 'which_key' },
      command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
    })
  end,
}
