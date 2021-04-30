local G = require 'core.global'

if vim.fn.executable(G.sumneko_binary) then
  require'lspconfig'.sumneko_lua.setup {
    cmd = {G.sumneko_binary, "-E", G.sumneko_root_path .. "/main.lua"},
    handlers = require'modules.lang.lsp.lspconfig.utils'.diagnostics,
    capabilities = require'modules.lang.lsp.servers'.capabilities,
    on_attach = require'modules.lang.lsp.servers'.enhance_attach,
    settings = {
      Lua = {
        runtime = {version = "LuaJIT", path = vim.split(package.path, ';')},
        diagnostics = {enable = true, globals = {"vim", "packer_plugins"}},
        workspace = {library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true}}
      }
    }
  }
end
