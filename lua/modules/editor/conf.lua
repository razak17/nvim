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

function config.rnvimr()
  -- Make Ranger replace netrw and be the file explorer
  vim.g.rnvimr_ex_enable = 1
  vim.g.rnvimr_draw_border = 1

  -- Make Ranger to be hidden after picking a file
  vim.g.rnvimr_pick_enable = 1

  -- Make Neovim to wipe the buffers corresponding to the files deleted by Ranger
  vim.g.rnvimr_bw_enable = 1

  -- Change the border's color
  vim.g.rnvimr_border_attr = {fg = 12, bg = -1}
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

function config.floaterm()
  vim.g.floaterm_borderchars = {
    '─', '│', '─', '│', '╭', '╮', '╯', '╰'
  }

  vim.cmd [[ autocmd FileType floaterm setlocal winblend=0 ]]

  -- vim.g.floaterm_wintype='normal'
  vim.g.floaterm_keymap_new = '<F7>'
  vim.g.floaterm_keymap_prev = '<F8>'
  vim.g.floaterm_keymap_next = '<F9>'
  -- vim.g.floaterm_keymap_kill   = '<F10>'
  vim.g.floaterm_keymap_toggle = '<F12>'

  vim.g.floaterm_gitcommit = 'floaterm'
  vim.g.floaterm_autoinsert = 1
  vim.g.floaterm_width = 0.8
  vim.g.floaterm_height = 0.9
  vim.g.floaterm_wintitle = ''
  vim.g.floaterm_autoclose = 1
end

return config
