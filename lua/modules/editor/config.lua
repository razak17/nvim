local config = {}

function config.nvim_colorizer()
  require'colorizer'.setup {
    '*',
    css = {rgb_fn = true},
    scss = {rgb_fn = true, hsl_fn = true},
    sass = {rgb_fn = true},
    stylus = {rgb_fn = true},
    vim = {names = true},
    tmux = {names = false},
    lua = {names = false},
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    html = {mode = 'foreground'}
  }
end

function config.dial()
  local dial = require("dial")

  dial.augends["custom#boolean"] = dial.common.enum_cyclic {
    name = "boolean",
    strlist = {"true", "false"}
  }
  table.insert(dial.config.searchlist.normal, "custom#boolean")
  vim.cmd([[
    nmap <C-a> <Plug>(dial-increment)
    nmap <C-x> <Plug>(dial-decrement)
    vmap <C-a> <Plug>(dial-increment)
    vmap <C-x> <Plug>(dial-decrement)
    vmap g<C-a> <Plug>(dial-increment-additional)
    vmap g<C-x> <Plug>(dial-decrement-additional)
  ]])
end

function config.tagalong()
  vim.g.tagalong_filetypes = {
    'html',
    'xml',
    'jsx',
    'eruby',
    'ejs',
    'eco',
    'php',
    'htmldjango',
    'javascriptreact',
    'typescriptreact',
    'javascript'
  }
  vim.g.tagalong_verbose = 1
end

function config.autopairs()
  require('nvim-autopairs').setup({
    pairs_map = {
      ["'"] = "'",
      ['"'] = '"',
      ['('] = ')',
      ['['] = ']',
      ['{'] = '}',
      ['`'] = '`'
    },
    disable_filetype = {"TelescopePrompt", "vim"}
  })
end

return config
