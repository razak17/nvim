local vim = vim
local lspconfig = require('lspconfig')
local on_attach = require('lsp/on_attach')
local G = require('global')

local sumneko_root_path = G.cache_dir ..'nvim_lsp/lua-language-server/'
local sumneko_binary = sumneko_root_path..'/bin/Linux/lua-language-server'

function Root_Pattern_Prefer(...)
  local patterns = vim.tbl_flatten {...}
  return function(startpath)
    for _, pattern in ipairs(patterns) do
      local path = lspconfig.util.root_pattern(pattern)(startpath)
      if path then return path end
    end
  end
end

-- Set up completion
require('lsp/completion').setup()

-- Diagnostics handlers
require('lsp/diagnostics').handlers()

-- Individual server conf
require('lsp/conf').setup()

-- List of servers where config = {on_attach = on_attach}
local servers = {'bashls', 'sumneko_lua', 'tsserver'}

for _, server in ipairs(servers) do
  if server == "tsserver" then
    -- tsserver
    lspconfig[server].setup {
      on_attach = on_attach,
      root_dir = Root_Pattern_Prefer("tsconfig.json", "package.json", ".git")
    }
  elseif server == "bashls" then
    lspconfig[server].setup {

    }
  elseif server == "sumneko_lua" then
    lspconfig[server].setup {
      cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
      on_attach = on_attach,
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
            path = vim.split(package.path, ';'),
          },
          diagnostics = {
            enable = true,
            globals = {'vim'},
          },
          workspace = {
            library = {
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            },
          },
        },
      },
    }
  else
    lspconfig[server].setup {
      on_attach = on_attach,
    }
  end
end

