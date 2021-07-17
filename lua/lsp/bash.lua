local M = {}
function M.setup(capabilities)
  if vim.fn.executable("bash-language-server") then
    require'lspconfig'.bashls.setup {
      cmd_env = {GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"},
      filetypes = {"sh", "zsh"},
      capabilities = capabilities,
      on_attach = core.lsp.on_attach,
    }
  end
end

return M
