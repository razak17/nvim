local lsp = require 'lsp'

if vim.fn.executable(core.__sumneko_binary) then
  require'lspconfig'.sumneko_lua.setup {
    cmd = {core.__sumneko_binary, "-E", core.__sumneko_root_path .. "/main.lua"},
    capabilities = lsp.capabilities,
    on_attach = lsp.enhance_attach,
    settings = {
      Lua = {
        runtime = {version = "LuaJIT", path = vim.split(package.path, ';')},
        diagnostics = {globals = {"vim", "packer_plugins"}},
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 1000,
        },
      },
    },
  }
end
