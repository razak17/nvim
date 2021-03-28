local G = require "core.global"
local cmd, fn = vim.cmd, vim.fn

local function createDirs()
  -- Create all cache directories
  local data_dir = {
    G.cache_dir .. "backup", G.cache_dir .. "session", G.cache_dir .. "swap",
    G.cache_dir .. "tags", G.cache_dir .. "undodir", G.cache_dir .. "nvim_lsp"
  }
  if not G.isdir(G.cache_dir) then
    os.execute("mkdir -p " .. G.cache_dir)
  end
  for _, v in pairs(data_dir) do
    if not G.isdir(v) then
      os.execute("mkdir -p " .. v)
    end
  end
end

local function pythonvenvInit()
  if not G.isdir(G.python3) and fn.executable("python3") then
    os.execute("mkdir -p " .. G.python3)
    os.execute("python3 -m venv " .. G.python3)
    cmd("!" .. G.python3 .. "bin" .. G.path_sep ..
            "pip3 install -U setuptools pynvim jedi isort neovim-remote")
  end
end

local function golangInit()
  if G.exists(G.golang) then
    local needs_install = {
      ['efm-langserver'] = 'github.com/mattn/efm-langserver',
      gopls = 'golang.org/x/tools/gopls@latest'
    }
    for i, v in pairs(needs_install) do
      if fn.executable(i) == 0 then
        os.execute("go get " .. v)
      end
    end
  end
end

local function nodeHostInit()
  if fn.executable("npm") then
    local simple_lsp = {
      ['vscode-json-languageserver'] = "vscode-json-languageserver",
      ['css-languageserver'] = "vscode-css-languageserver-bin",
      ['docker-langserver'] = "dockerfile-language-server-nodejs",
      ['graphql-lsp'] = "graphql-language-service-cli",
      ['html-languageserver'] = "vscode-html-languageserver-bin",
      ['svelteserver'] = "svelte-language-server",
      ['vim-language-server'] = "vim-language-server",
      ['yaml-language-server'] = "yaml-language-server",
      ['bash-language-server'] = "bash-language-server",
      ['sql-language-server'] = "sql-language-server",
      ['typescript-language-server'] = 'typescript-language-server',
      ['tsserver'] = 'typescript',
      ['pyright'] = 'pyright'
    }
    for i, v in pairs(simple_lsp) do
      if fn.executable(i) == 0 then
        os.execute("npm install -g " .. v)
      end
    end
    if not G.exists(G.node) then
      os.execute("npm install -g neovim")
    end
  end
end

local function packerInit()
  if not G.isdir(G.plugins .. "packer" .. G.path_sep .. "opt" .. G.path_sep ..
                     "packer.nvim") then
    fn.mkdir(G.plugins .. "opt", "p")
    local out = fn.system(string.format("git clone %s %s",
                                        "https://github.com/wbthomason/packer.nvim",
                                        G.plugins .. "packer" .. G.path_sep ..
                                            "opt" .. G.path_sep .. "packer.nvim"))
    print(out)
    print("Downloading packer.nvim...")
    cmd("set runtimepath+=" .. G.plugins .. "opt" .. G.path_sep .. "packer.nvim")
    require"core.pack".install()
  end
end

createDirs()
pythonvenvInit()
nodeHostInit()
golangInit()
packerInit()
