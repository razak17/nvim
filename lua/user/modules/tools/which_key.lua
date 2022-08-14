return function()
  if not rvim.plugin_installed('which-key.nvim') then return end

  local icons = rvim.style.icons
  local which_key = require('which-key')

  which_key.setup({
    plugins = {
      spelling = { enabled = true },
    },
    icons = { breadcrumb = icons.misc.double_chevron_right },
    window = { border = rvim.style.border.current },
    layout = { align = 'center' },
    hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' },
    show_help = true,
  })

  local function installed(name, desc)
    if rvim.plugin_installed(name) then return desc end
    return 'not installed'
  end

  which_key.register({
    [']'] = {
      name = '+next',
      ['<space>'] = 'add space below',
    },
    ['['] = {
      name = '+prev',
      ['<space>'] = 'add space above',
    },
    ['<leader>'] = {
      a = { name = 'Actions' },
      b = { name = 'Bufferline' },
      C = { name = 'Change' },
      F = { name = 'Fold' },
      g = { name = 'Git' },
      i = { name = 'Swap' },
      l = { name = 'Lsp' },
      L = { name = 'rVim' },
      m = { name = 'Marks' },
      n = { name = 'Notify' },
      o = { name = 'Toggle' },
      p = { name = 'Packer' },
      s = { name = 'Snip' },
      t = { name = 'Term' },
      r = { name = 'Remove' },
    },
    ['<localleader>'] = {
      d = { name = 'Dap' },
      g = { name = 'Git' },
      l = { name = 'lsp' },
      p = 'markdown-preview: toggle',
      w = { name = 'Window' },
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
