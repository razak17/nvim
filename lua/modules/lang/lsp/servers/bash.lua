local lsp_servers = require 'modules.lang.lsp.servers'

if vim.fn.executable("bash-language-server") then
  require'lspconfig'.bashls.setup {
    cmd_env = {GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"},
    filetypes = {"sh", "zsh"},
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach
  }
end
