return {
  'RRethy/vim-illuminate',
  event = 'BufReadPost',
  enabled = false,
  config = function()
    require('illuminate').configure({
      filetypes_denylist = {
        'alpha',
        'NvimTree',
        'DressingInput',
        'dashboard',
        'neo-tree',
        'neo-tree-popup',
        'qf',
        'lspinfo',
        'lsp-installer',
        'TelescopePrompt',
        'harpoon',
        'packer',
        'mason.nvim',
        'help',
        'CommandTPrompt',
        'buffer_manager',
        'dapui_scopes',
        'dapui_breakpoints',
        'dapui_stacks',
        'dapui_watches',
        'dapui_console',
        'dap-repl',
      },
    })
    rvim.nnoremap(
      '<a-n>',
      ':lua require"illuminate".next_reference{wrap=true}<CR>',
      'illuminate: next'
    )
    rvim.nnoremap(
      '<a-p>',
      ':lua require"illuminate".next_reference{reverse=true,wrap=true}<CR>',
      'illuminate: reverse'
    )
  end,
}
