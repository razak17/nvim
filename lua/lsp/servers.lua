local M = {}

function M.setup()
  require("lsp").setup "c"
  -- require("lsp").setup "cmake"
  require("lsp").setup "cpp"
  require("lsp").setup "css"
  require("lsp").setup "docker"
  require("lsp").setup "elixir"
  require("lsp").setup "go"
  require("lsp").setup "graphql"
  require("lsp").setup "html"
  require("lsp").setup "json"
  require("lsp").setup "lua"
  require("lsp").setup "python"
  -- require("lsp").setup "rust"
  require("lsp").setup "sh"
  require("lsp").setup "vim"
  require("lsp").setup "yaml"
  require("lsp").setup "javascript"
  require("lsp").setup "javascriptreact"
  require("lsp").setup "typescript"

  vim.cmd "doautocmd User LspServersStarted"
end

return M
