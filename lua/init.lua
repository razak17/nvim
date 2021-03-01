local load_config = require 'utils.funcs'.load_config

if vim.fn.exists('g:vscode') == 0 then
  load_config('setup')
  load_config('conf')
end

load_config('opts')
load_config('binds')
load_config('plugins')

if vim.fn.exists('g:vscode') == 0 then
  load_config('utils', 'cmd')
  load_config('autocmd')
  load_config('aesth', 'bg')
  load_config('aesth', 'hijackc')
  load_config('aesth', 'statusline')

  -- Plugins
  load_config('plugin', 'ts', 'stp')
  load_config('plugin', 'autopairs')
  load_config('plugin', 'bufferline')
  load_config('plugin', 'colorizer')
  load_config('plugin', 'compe')
  load_config('plugin', 'cool')
  load_config('plugin', 'emmet')
  load_config('plugin', 'far')
  load_config('plugin', 'floaterm')
  load_config('plugin', 'illuminate')
  load_config('plugin', 'lsp')
  load_config('plugin', 'rooter')
  load_config('plugin', 'tagalong')
  load_config('plugin', 'telescope')
  load_config('plugin', 'tree')
  load_config('plugin', 'vsnip')
  load_config('plugin', 'which-key')
end
