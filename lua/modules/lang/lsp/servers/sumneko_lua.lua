local G = require 'core.globals'
local lsp_servers = require 'modules.lang.lsp.servers'

if vim.fn.executable(G.sumneko_binary) then
  require'lspconfig'.sumneko_lua.setup {
    cmd = {G.sumneko_binary, "-E", G.sumneko_root_path .. "/main.lua"},
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach,
    settings = {
      Lua = {
        runtime = {version = "LuaJIT", path = vim.split(package.path, ';')},
        diagnostics = {enable = true, globals = {"vim", "packer_plugins"}},
        workspace = {library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true}}
      }
    }
  }
end
