local vim = vim
local g = vim.g
local G = require 'global'
local current_dir = vim.fn.getcwd()

g.startify_session_dir = G.cache_dir .. "session"
g.startify_session_autoload = 1
g.startify_session_delete_buffers = 1
g.startify_change_to_vcs_root = 1
g.startify_fortune_use_unicode = 1
g.startify_session_persistence = 1
g.startify_enable_special = 0
g.webdevicons_enable_startify = 0

g.startify_lists = {
  { type = 'files',     header = { '   Files' }                    },
  { type = 'dir',       header = { '   Current Directory ' .. current_dir } },
  { type = 'sessions',  header = { '   Sessions' }                 },
  { type = 'bookmarks', header = { '   Bookmarks' }                },
 }

g.startify_bookmarks = {
  { a = '~/.config/zsh/aliases.zsh' },
  { b = '~/.bashrc' },
  { i = '~/.config/nvim/init.vim' },
  { t = '~/.tmux.conf' },
  { z = '~/.zshrc' },
  '~/Dev/Scripts',
  '~/Dev/Code/cp',
  '~/Dev/Code/learn',
  '~/Dev/Code/python',
  '~/Dev/Code/web',
  '~/Dev/Code/projects',
}

