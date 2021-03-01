local G = require "global"
local cmd, fn = vim.cmd, vim.fn

local function createDirs()
    -- Create all cache directories
    -- Install python virtualenv and language server
    local data_dir = {
        G.cache_dir .. "backup",
        G.cache_dir .. "session",
        G.cache_dir .. "swap",
        G.cache_dir .. "tags",
        G.cache_dir .. "undodir",
        G.cache_dir .. "nvim_lsp"
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
        -- install python language server, neovim host, and neovim remote
        cmd(
            "!" ..
                G.python3 ..
                    "bin" ..
                        G.path_sep ..
                            "pip3 install -U setuptools pynvim jedi 'python-language-server[all]' isort pyls-isort neovim-remote"
        )
    end
end

local function nodeHostInit()
  if fn.executable("npm") then
    -- install neovim node host
    if not G.exists(G.node) then
      local needs_install = {
        "neovim",
        "bash-language-server",
        "vscode-css-languageserver-bin",
        "dockerfile-language-server-nodejs",
        "graphql-language-service-cli",
        "vscode-html-languageserver-bin",
        "vscode-json-languageserver",
        "sql-language-server",
        "svelte-language-server",
        "typescript",
        "typescript-language-server",
        "vim-language-server",
        "vls",
        "yaml-language-server"
      }
      for _, v in pairs(needs_install) do
        os.execute("npm install -g " .. v)
      end
      os.execute("npm install -g neovim")
    end
  end
end

local function packerInit()
    if not G.isdir(G.plugins .. "packer" .. G.path_sep .. "opt" .. G.path_sep .. "packer.nvim") then
        fn.mkdir(G.plugins .. "opt", "p")
        local out =
            fn.system(
            string.format(
                "git clone %s %s",
                "https://github.com/wbthomason/packer.nvim",
                G.plugins .. "packer" .. G.path_sep .. "opt" .. G.path_sep .. "packer.nvim"
            )
        )
        print(out)
        print("Downloading packer.nvim...")
        cmd("set runtimepath+=" .. G.plugins .. "opt" .. G.path_sep .. "packer.nvim")
        require "plugins".install()
    end
end

if vim.fn.exists('g:vscode') == 0 then
  createDirs()
  pythonvenvInit()
  nodeHostInit()
  packerInit()
end
