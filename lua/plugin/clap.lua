local opts = {noremap = true, silent = true}
local mapk = vim.api.nvim_set_keymap
local g = vim.g

g.clap_layout = { width = '67%', height = '33%', row = '33%', col = '17%' }

g.clap_provider_quick_open = {
  source =  { '~/.vimrc', '~/.spacevim', '~/.bashrc', '~/.tmux.conf' },
  sink = 'e',
  description =  'Quick open some dotfiles',
}

mapk('n', '<c-k>', ':Clap<CR>', opts)

