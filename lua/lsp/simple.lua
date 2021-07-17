local simple_lsp = {
  jsonls = "vscode-json-language-server",
  cssls = "vscode-css-language-server",
  html = "vscode-html-language-server",
  dockerls = "docker-langserver",
  graphql = "graphql-lsp",
  vimls = "vim-language-server",
  yamlls = "yaml-language-server",
}

local M = {}
function M.setup(capabilities, on_init)
  for server, exec in pairs(simple_lsp) do
    if vim.fn.executable(exec) then
      require'lspconfig'[server].setup {
        capabilities = capabilities,
        on_attach = core.lsp.on_attach,
        on_init = on_init,
        root_dir = require'lspconfig.util'.root_pattern('.gitignore', '.git', vim.fn.getcwd()),
      }
    end
  end
end

return M
