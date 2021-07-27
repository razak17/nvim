local M = {}

M.init = function()
  if rvim.check_lsp_client_active "gopls" then
    return
  end
  require'lspconfig'.gopls.setup {
    cmd = {rvim.lsp.binary.go, "--remote=auto"},
    capabilities = rvim.lsp.capabilities,
    on_attach = rvim.lsp.on_attach,
    init_options = {usePlaceholders = true, completeUnimported = true},
    root_dir = require'lspconfig.util'.root_pattern('main.go', '.gitignore', '.git', vim.fn.getcwd()),
  }
end

M.format = function()
  local filetype = {}
  filetype["go"] = {
    function()
      return {exe = "gofmt", args = {}, stdin = true}
    end,
  }
  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.lint = function()
  require("lint").linters_by_ft = {go = {"golangcilint", "revive"}}
end

return M

