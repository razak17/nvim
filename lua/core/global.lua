local G = {}
local home = os.getenv("HOME")
local path_sep = G.is_windows and '\\' or '/'
local os_name = vim.loop.os_uname().sysname

function G:load_variables()
  self.home = home .. path_sep
  self.path_sep = path_sep
  self.is_mac = os_name == 'OSX'
  self.is_linux = os_name == 'Linux'
  self.is_windows = os_name == 'Windows'
  self.cache_dir = G.home .. '.cache' .. path_sep .. 'nvim' .. path_sep
  self.vim_path = vim.fn.stdpath('config')
  self.data_dir = string.format('%s/site/', vim.fn.stdpath('data')) .. path_sep
  self.asdf = G.home .. '.asdf' .. path_sep .. 'installs' .. path_sep
  self.python3 = G.cache_dir .. 'venv' .. path_sep .. 'neovim' .. path_sep
  self.golang = G.asdf .. "golang/1.16.2/go/bin/go"
  self.node = G.asdf .. "nodejs/15.5.1/.npm/bin/neovim-node-host"
  self.plugins = G.data_dir .. 'pack' .. path_sep
  self.nvim_lsp = G.cache_dir .. 'nvim_lsp' .. path_sep
  self.sumneko_root_path = G.nvim_lsp .. 'lua-language-server' .. path_sep
  self.elixirls_root_path = G.nvim_lsp .. 'elixir-ls' .. path_sep
  self.sumneko_binary = G.sumneko_root_path .. '/bin/Linux/lua-language-server'
  self.elixirls_binary = G.elixirls_root_path .. '/.bin/language_server.sh'
end

--- Check if a file or directory exists in this path
function G.exists(file)
  if file == '' or file == nil then
    return false
  end
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  return ok, err
end

--- Check if a directory exists in this path
function G.isdir(path)
  if path == '' or path == nil then
    return false
  end
  -- "/" works on both Unix and Windows
  return G.exists(path .. "/")
end

G:load_variables()

return G

