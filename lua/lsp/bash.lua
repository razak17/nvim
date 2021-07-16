local lsp = require 'lsp'

if vim.fn.executable("bash-language-server") then
  require'lspconfig'.bashls.setup {
    cmd_env = {GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"},
    filetypes = {"sh", "zsh"},
    capabilities = lsp.capabilities,
    on_attach = lsp.enhance_attach,
  }
end
