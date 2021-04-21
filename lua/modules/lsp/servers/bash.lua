if vim.fn.executable("bash-language-server") then
  require'lspconfig'.bashls.setup {
    cmd_env = {GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"},
    filetypes = {"sh", "zsh"},
    on_attach = require'modules.lsp.servers'.enhance_attach
  }
end
