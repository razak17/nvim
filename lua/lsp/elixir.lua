local M = {}

M.init = function()
  if rvim.check_lsp_client_active "elixirls" then
    return
  end
  require'lspconfig'.elixirls.setup {
    cmd = {rvim.lang.lsp.binary.elixir},
    elixirls = {dialyzerEnabled = false},
    capabilities = rvim.lang.lsp.capabilities,
    on_attach = rvim.lang.lsp.on_attach,
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
