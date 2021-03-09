local config = {}

function config.colorizer()
  require 'colorizer'.setup(
      {'*';},
      {
        RGB      = true;         -- #RGB hex codes
        RRGGBB   = true;         -- #RRGGBB hex codes
        names    = false;         -- "Name" codes like Blue
        RRGGBBAA = true;         -- #RRGGBBAA hex codes
        rgb_fn   = true;         -- CSS rgb() and rgba() functions
        hsl_fn   = true;         -- CSS hsl() and hsla() functions
        css      = true;         -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn   = true;         -- Enable all CSS *functions*: rgb_fn, hsl_fn
      }
  )
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
    },
    disable_filetype = { "TelescopePrompt" , "vim" },
  })
end

function config.floaterm()
  vim.g.floaterm_borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'}
  -- vim.g.floaterm_borderchars = {'═', '║', '═', '║', '╔', '╗', '╝', '╚'}

  -- Set floaterm window's background to black
  vim.cmd [[ hi FloatermBorder guifg=#51afef ]]
  vim.cmd [[ autocmd FileType floaterm setlocal winblend=0 ]]

  -- vim.g.floaterm_wintype='normal'
  vim.g.floaterm_keymap_new    = '<F7>'
  vim.g.floaterm_keymap_prev   = '<F8>'
  vim.g.floaterm_keymap_next   = '<F9>'
  -- vim.g.floaterm_keymap_kill   = '<F10>'
  vim.g.floaterm_keymap_toggle = '<F12>'

  -- Floaterm
  vim.g.floaterm_gitcommit='floaterm'
  vim.g.floaterm_autoinsert=1
  vim.g.floaterm_width=0.8
  vim.g.floaterm_height=0.8
  vim.g.floaterm_wintitle=''
  vim.g.floaterm_autoclose=1
end

return config
