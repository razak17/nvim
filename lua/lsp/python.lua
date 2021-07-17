local M = {}

M.setup = function(capabilities)
  if vim.fn.executable("pyright-langserver") then
    require'lspconfig'.pyright.setup {
      capabilities = capabilities,
      on_attach = core.lsp.on_attach,
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "off",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
    }
  end
end

M.lint = function() require("lint").linters_by_ft = {python = {"flake8", "pylint", "mypy"}} end

return M

