local G = require "core.global"
local cmd, fn = vim.cmd, vim.fn

local function createDirs()
    -- Create all cache directories
    -- Install python virtualenv and language server
    local data_dir = {
        G.cache_dir .. "backup", G.cache_dir .. "session",
        G.cache_dir .. "swap", G.cache_dir .. "tags", G.cache_dir .. "undodir",
        G.cache_dir .. "nvim_lsp"
    }
    if not G.isdir(G.cache_dir) then os.execute("mkdir -p " .. G.cache_dir) end
    for _, v in pairs(data_dir) do
        if not G.isdir(v) then os.execute("mkdir -p " .. v) end
    end
end

local function pythonvenvInit()
    if not G.isdir(G.python3) and fn.executable("python3") then
        os.execute("mkdir -p " .. G.python3)
        os.execute("python3 -m venv " .. G.python3)
        -- install python language server, neovim host, and neovim remote
        cmd("!" .. G.python3 .. "bin" .. G.path_sep ..
                "pip3 install -U setuptools pynvim jedi isort neovim-remote")
    end
end

local function golangInit()
    if not G.exists(G.golang) then
        local needs_install = {
            ['efm-langserver'] = 'github.com/mattn/efm-langserver',
            gopls = 'golang.org/x/tools/gopls@latest'
        }
        for i, v in pairs(needs_install) do
            if fn.executable(i) == 0 then os.execute("go get " .. v) end
        end
    end
end

local function nodeHostInit()
    if fn.executable("npm") then
        -- install neovim node host
        if not G.exists(G.node) then
            local needs_install = {
                "typescript", "typescript-language-server",
                "bash-language-server", "dockerfile-language-server-nodejs",
                "graphql-language-service-cli", "vim-language-server",
                "yaml-language-server", "vscode-css-languageserver-bin",
                "vscode-html-languageserver-bin", "vscode-json-languageserver",
                "sql-language-server", "svelte-language-server", "vls"
            }
            print("Installing lsp servers...")
            for _, v in pairs(needs_install) do
                if fn.executable(v) == 0 then
                    os.execute("npm install -g " .. v)
                end
            end
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
                                                "opt" .. G.path_sep ..
                                                "packer.nvim"))
        print(out)
        print("Downloading packer.nvim...")
        cmd("set runtimepath+=" .. G.plugins .. "opt" .. G.path_sep ..
                "packer.nvim")
        require"core.pack".install()
    end
end

createDirs()
pythonvenvInit()
nodeHostInit()
-- golangInit()
packerInit()
