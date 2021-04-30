local lsp_servers = require 'modules.lang.lsp.servers'
local lsp_utils = require 'modules.lang.lsp.lspconfig.utils'

if vim.fn.executable("bash-language-server") then
  require'lspconfig'.bashls.setup {
    cmd_env = {GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"},
    filetypes = {"sh", "zsh"},
    handlers = lsp_utils.diagnostics,
    capabilities = lsp_servers.capabilities,
    on_attach = lsp_servers.enhance_attach
  }
end
