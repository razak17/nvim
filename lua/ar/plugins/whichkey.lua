return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    icons = {
      rules = false,
      keys = { CR = '↪', TAB = '→', Space = '󱁐 ' },
    },
    win = {
      col = 0.5,
      height = { min = 10, max = 25 },
      border = ar.ui.current.border,
      wo = {
        winblend = ar.ui.transparent.enable and 0 or 12, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      },
    },
    preset = 'classic',
    layout = { align = 'center' },
    spec = {
      {
        mode = { 'n' },
        { '<leader>[', group = 'Replace all' },
        { '<leader>]', group = 'Replace in line' },
        { '<leader>A', group = 'Animations' },
        { '<leader>F', group = 'Picker (Current Dir)' },
        { '<leader>a', group = 'A.I.' },
        { '<leader>ac', group = 'CopilotChat' },
        { '<leader>ac', group = 'Codecompanion' },
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
        { '<leader>q', group = 'Quit/Session' },
        { '<leader>r', group = 'Run' },
        { '<leader>rk', group = 'Kulala' },
        { '<leader>s', group = 'Splits' },
        { '<leader>t', group = 'Testing' },
        { '<leader>tc', group = 'Coverage' },
        { '<leader>tn', group = 'Neotest' },
        { '<leader>to', group = 'Overseer' },
        { '<leader>tv', group = 'Vim-test' },
        { '<leader>u', group = 'UI' },
        { '<leader>v', group = 'Vim' },
        { '<leader>w', group = 'Window' },
        { '<leader>wm', group = 'Maximizer' },
        { '<localleader>a', group = 'Actions' },
        { '<localleader>b', group = 'Buffer' },
        { '<localleader>c', group = 'Conceal' },
        { '<localleader>d', group = 'Dap' },
        { '<localleader>db', group = 'Breakpoint' },
        { '<localleader>dr', group = 'Run' },
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
        { '<localleader>p', group = 'Pad' },
        { '<localleader>p', group = 'Project' },
        { '<localleader>q', group = 'NeoComposer' },
        { '<localleader>r', group = 'Monorepo' },
        { '<localleader>s', group = 'Strict' },
        { '<localleader>t', group = 'TODO' },
        { '<localleader>u', group = 'URL' },
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
        { '<leader><leader>m', desc = 'Markdown' },
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
        { '<leader>u', group = 'UI' },
        { '<localleader>S', group = 'Sort' },
        { '<localleader>a', group = 'A.I.' },
        { '<localleader>g', group = 'Git' },
        { '<localleader>h', group = 'Gitsigns' },
        { '<localleader>l', group = 'LSP' },
        { '<leader><leader>m', desc = 'Markdown' },
        { '<leader><leader>ml', desc = 'Link' },
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
