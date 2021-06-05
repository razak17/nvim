local lsp_servers = require 'modules.lang.lsp.servers'

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
      capabilities = lsp_servers.capabilities,
      on_attach = lsp_servers.enhance_attach,
      on_init = lsp_servers.on_init,
      root_dir = require'lspconfig.util'.root_pattern('.gitignore', '.git',
                                                      vim.fn.getcwd())
    }
  end
end
