local M = {}

M.init = function()
  if core.check_lsp_client_active "pyright" then
    return
  end
  require'lspconfig'.pyright.setup {
    cmd = {core.lsp.binary.python, "--stdio"},
    capabilities = core.lsp.capabilities,
    on_attach = core.lsp.on_attach,
    settings = {
      python = {
        analysis = {typeCheckingMode = "off", autoSearchPaths = true, useLibraryCodeForTypes = true},
      },
    },
  }
end

M.format = function()
  local filetype = {}
  filetype["python"] = {
    function()
      return {exe = "yapf", args = {}, stdin = true}
    end,
  }

  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.lint = function()
  require("lint").linters_by_ft = {
    python = {
      "flake8",
      -- "pylint",
      -- "mypy"
    },
  }
end

return M
