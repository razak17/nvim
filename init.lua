local g, fn, cmd = vim.g, vim.fn, vim.cmd
local os_name = vim.loop.os_uname().sysname

if fn.filereadable(fn.fnamemodify("~/.config/rvim/external/utils/.vimrc.local", ":p")) > 0 then
  cmd [[source ~/.config/rvim/external/utils/.vimrc.local]]
end

-- GLobal directories
g.home = os.getenv "HOME"
g.is_mac = os_name == "OSX"
g.is_linux = os_name == "Linux"
g.is_windows = os_name == "Windows"
g.vim_path = g.home .. "/.config/rvim"
g.cache_dir = g.home .. "/.cache/rvim"
g.data_dir = g.home .. "/.local/share/rvim"
g.fnm_dir= g.home .. "/.fnm/node-versions"
g.node_dir= g.fnm_dir .. "/v16.3.0/installation/bin/neovim-node-host"
g.python_dir= g.cache_dir .. "/venv/neovim"
g.plugins_dir= g.data_dir .. "/pack"
g.lsp_dir= g.cache_dir .. "/nvim_lsp"
g.dap_install_dir = g.cache_dir .. "/dap"
g.dap_python = g.dap_install_dir  .. "/python_dbg/bin/python"
g.dap_node = g.dap_install_dir  .. "/jsnode_dbg/vscode-node-debug2/out/src/nodeDebug.js"
g.vsnip_dir = g.vim_path .. "/external/snippets"
g.templates_dir = g.home .. "/external/templates"
g.session_dir = g.cache_dir .. "/session/dashboard"
g.modules_dir = g.vim_path .. '/lua/modules'
g.sumneko_root_path = g.lsp_dir .. "/lua-language-server"
g.elixirls_root_path = g.lsp_dir .. "/elixir-ls"
g.open_command = g.os == "Darwin" and "open" or "xdg-open"
g.python3_host_prog = g.python_dir .. "/bin/python"
g.node_host_prog = g.node_dir

-- Load Modules
require "core"

-- override leader key
g.mapleader = rvim.utils.leader_key
g.maplocalleader = rvim.utils.leader_key
