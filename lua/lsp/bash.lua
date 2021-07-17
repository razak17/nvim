local M = {}

M.setup = function(capabilities)
  require'lspconfig'.bashls.setup {
    cmd_env = {GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"},
    filetypes = {"sh", "zsh"},
    capabilities = capabilities,
    on_attach = core.lsp.on_attach,
  }
end

return M
