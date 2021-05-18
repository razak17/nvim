local config = {}

function config.delimimate()
  vim.g.delimitMate_expand_cr = 0
  vim.g.delimitMate_expand_space = 1
  vim.g.delimitMate_smart_quotes = 1
  vim.g.delimitMate_expand_inside_quotes = 0
  vim.api.nvim_command(
      'au FileType markdown let b:delimitMate_nesting_quotes = ["`"]')
end

function config.nvim_colorizer()
  require'colorizer'.setup {
    css = {rgb_fn = true},
    scss = {rgb_fn = true, hsl_fn = true},
    sass = {rgb_fn = true},
    stylus = {rgb_fn = true},
    vim = {names = true},
    tmux = {names = false},
    lua = {names = false},
    python = {names = false},
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'tmux',
    'yaml',
    'lua',
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

function config.autopairs()
  require('nvim-autopairs').setup({
    pairs_map = {
      ["'"] = "'",
      ['"'] = '"',
      ['('] = ')',
      ['['] = ']',
      ['{'] = '}',
      ['`'] = '`',
      ['<'] = '>'
    },
    disable_filetype = {"TelescopePrompt", "vim", "lua", "c", "cpp"}
  })
end

function config.kommentary()
  require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true
  })
end

return config
