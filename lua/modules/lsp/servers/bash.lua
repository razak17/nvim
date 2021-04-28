if vim.fn.executable("bash-language-server") then
  require'lspconfig'.bashls.setup {
    cmd_env = {GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"},
    filetypes = {"sh", "zsh"},
    handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
    capabilities = require'modules.lsp.servers'.capabilities,
    on_attach = require'modules.lsp.servers'.enhance_attach,
  }
end
