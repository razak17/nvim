local M = {}

M.init = function()
  require'lspconfig'.elixirls.setup {
    cmd = {core.lsp.binary.elixir},
    elixirls = {dialyzerEnabled = false},
    capabilities = core.lsp.capabilities,
    on_attach = core.lsp.on_attach,
  }
end

M.format = function()
  local filetype = {}
  filetype["elixir"] = {
    function()
      return {exe = "mix", args = {"format"}, stdin = true}
    end,
  }

  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.lint = function()
  -- TODO: implement linters (if applicable)
  return "No linters configured!"
end

return M
