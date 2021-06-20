_GlobalCallbacks = _GlobalCallbacks or {}

_G.r17 = {_store = _GlobalCallbacks}

require("core.globals.utils")

local home = os.getenv("HOME")
local os_name = vim.loop.os_uname().sysname

local G = {}
local path_sep = G.is_windows and '\\' or '/'

function G:load_variables()
  r17._home = home .. path_sep
  r17.__path_sep = path_sep
  r17.__is_mac = os_name == 'OSX'
  r17.__is_linux = os_name == 'Linux'
  r17.__is_windows = os_name == 'Windows'
  r17.__cache_dir = r17._home .. '.cache' .. path_sep .. 'nvim' .. path_sep
  r17.__vim_path = vim.fn.stdpath('config')
  r17.__data_dir = string.format('%s/site/', vim.fn.stdpath('data')) .. path_sep
  r17._asdf = r17._home .. '.asdf' .. path_sep .. 'installs' .. path_sep
  r17._fnm = r17._home .. '.fnm' .. path_sep .. 'node-versions' .. path_sep
  r17._dap = r17.__cache_dir .. 'venv' .. path_sep .. 'dap' .. path_sep
  r17._golang = r17._asdf .. "golang/1.16.2/go/bin/go"
  r17._node = r17._fnm .. "v16.3.0/installation/bin/neovim-node-host"
  r17._python3 = r17.__cache_dir .. 'venv' .. path_sep .. 'neovim' .. path_sep
  r17.__plugins = r17.__data_dir .. 'pack' .. path_sep
  r17.__nvim_lsp = r17.__cache_dir .. 'nvim_lsp' .. path_sep
  r17.__sumneko_root_path = r17.__nvim_lsp .. 'lua-language-server' .. path_sep
  r17.__elixirls_root_path = r17.__nvim_lsp .. 'elixir-ls' .. path_sep
  r17.__sumneko_binary = r17.__sumneko_root_path .. '/bin/Linux/lua-language-server'
  r17.__elixirls_binary = r17.__elixirls_root_path .. '/.bin/language_server.sh'
end

G:load_variables()

return G
