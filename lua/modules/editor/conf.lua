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
  vim.cmd("hi FloatermBorder guifg=#7ec0ee")
  vim.cmd("autocmd FileType floaterm setlocal winblend=0")

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

-- UTILS
function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  print(unpack(objects))
end

function config.makeScratch()
  vim.api.nvim_command('enew') -- equivalent to :enew
  vim.bo[0].buftype='nofile' -- set the current buffer's (buffer 0) buftype to nofile
  vim.bo[0].bufhidden='hide'
  vim.bo[0].swapfile=false
end

function config.OpenTerminal()
  vim.api.nvim_command("split term://zsh")
  vim.api.nvim_command("resize 10")
end

function config.TurnOnGuides()
  vim.cmd('set rnu')
  vim.cmd('set nu ')
  vim.cmd('set signcolumn=yes')
  vim.cmd('set colorcolumn=80')
end

function config.TurnOffGuides()
  vim.cmd('set nornu')
  vim.cmd('set nonu')
  vim.cmd('set signcolumn=no')
  vim.cmd('set colorcolumn=800')
end

function config.ToggleFold()
  local fold = false
  if fold then
    fold = false
    vim.cmd('set foldenable')
  else
    fold = true
    vim.cmd('set nofoldenable')
  end
end

return config

