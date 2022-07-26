return function()
  local icons = rvim.style.icons
  local which_key = require('which-key')

  which_key.setup({
    plugins = {
      marks = true, -- shows a list of your marks on ' and `
      registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      presets = {
        operators = false, -- adds help for operators like d, y, ...
        motions = false, -- adds help for motions
        text_objects = false, -- help for text objects triggered after entering an operator
        windows = true, -- default bindings on <c-w>
        nav = true, -- misc bindings to work with windows
        z = true, -- bindings for folds, spelling and others prefixed with z
        g = true, -- bindings for prefixed with g
      },
      spelling = { enabled = true, suggestions = 20 }, -- use which-key for spelling hints
    },
    icons = {
      breadcrumb = icons.misc.double_chevron_right, -- symbol used in the command line area that shows your active key combo
      group = '+', -- symbol prepended to a group
    },
    window = {
      border = rvim.style.border.current,
    },
    layout = {
      align = 'center',
    },
    hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' }, -- hide mapping boilerplate
    show_help = true, -- show help message on the command line when the popup is visible
  })

  which_key.register({
    ['<leader>'] = {
      a = '+Actions',
      b = '+Bufferline',
      C = 'Change',
      F = '+Fold',
      l = '+Lsp',
      L = 'rVim',
      n = 'Notify',
      p = '+Packer',
      s = 'Snip',
      r = 'Remove',
      z = 'Fold',
    },
    ['<localleader>'] = {
      d = 'Dap',
      L = 'rVim',
      w = 'Window',
    },
  })

  rvim.augroup('WhichKeyMode', {
    {
      event = { 'FileType' },
      pattern = { 'which_key' },
      command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
    },
  })
end
