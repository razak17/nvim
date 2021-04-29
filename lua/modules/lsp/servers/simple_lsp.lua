local simple_lsp = {
  jsonls = "vscode-json-languageserver",
  cssls = "css-languageserver",
  dockerls = "docker-langserver",
  graphql = "graphql-lsp",
  html = "html-languageserver",
  svelte = "svelteserver",
  vimls = "vim-language-server",
  yamlls = "yaml-language-server"
}

for lsp, exec in pairs(simple_lsp) do
  if vim.fn.executable(exec) then
    require'lspconfig'[lsp].setup {
      handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
      capabilities = require'modules.lsp.servers'.capabilities,
      on_attach = require'modules.lsp.servers'.enhance_attach,
      on_init = require'modules.lsp.servers'.on_init,
      root_dir = require'lspconfig.util'.root_pattern('.gitignore', '.git',
                                                      vim.fn.getcwd())
    }
  end
end
