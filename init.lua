local g, fn, cmd = vim.g, vim.fn, vim.cmd

-- Load base config
if fn.filereadable(fn.fnamemodify("~/.config/rvim/external/utils/.vimrc.local", ":p")) > 0 then
  cmd [[source ~/.config/rvim/external/utils/.vimrc.local]]
end

-- GLobal directories
g.os = vim.loop.os_uname().sysname
g.home = os.getenv "HOME"
g.is_mac = g.os == "OSX"
g.is_linux = g.os == "Linux"
g.is_windows = g.os == "Windows"
g.vim_path = g.home .. "/.config/rvim"
g.cache_dir = g.home .. "/.cache/rvim"
g.data_dir = g.home .. "/.local/share/rvim"
g.data_path = vim.fn.stdpath "data"
g.fnm_dir = g.home .. "/.fnm/node-versions"
g.node_dir = g.fnm_dir .. "/v16.3.0/installation/bin/neovim-node-host"
g.python_dir = g.cache_dir .. "/venv/neovim"
g.plugins_dir = g.data_dir .. "/pack"
g.lsp_dir = g.vim_path .. "/lua/lsp"
g.lspinstall_dir = g.data_path .. "/lspinstall"
g.dap_install_dir = g.cache_dir .. "/dap"
g.dap_python = g.dap_install_dir .. "/python_dbg/bin/python"
g.dap_node = g.dap_install_dir .. "/jsnode_dbg/vscode-node-debug2/out/src/nodeDebug.js"
g.vsnip_dir = g.vim_path .. "/external/snippets"
g.templates_dir = g.vim_path .. "/external/templates"
g.session_dir = g.cache_dir .. "/session/dashboard"
g.modules_dir = g.vim_path .. "/lua/modules"
g.sumneko_root_path = g.lspinstall_dir .. "/lua"
g.open_command = g.os == "Darwin" and "open" or "xdg-open"
g.python3_host_prog = g.python_dir .. "/bin/python"
g.node_host_prog = g.node_dir

-- Load Modules
require "core"
