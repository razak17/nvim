local M = {}

M.init = function()
  if core.check_lsp_client_active "yamlls" then
    return
  end
  require'lspconfig'.yamlls.setup {
    cmd = {core.lsp.binary.yaml, "--stdio"},
    capabilities = core.lsp.capabilities,
    on_attach = core.lsp.on_attach,
    root_dir = require'lspconfig.util'.root_pattern('.gitignore', '.git', vim.fn.getcwd()),
  }
end

M.format = function()
  local filetype = {}
  filetype["yaml"] = {
    function()
      return {
        exe = "prettier",
        args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote"},
        stdin = true,
      }
    end,
  }
  require("formatter.config").set_defaults {logging = false, filetype = filetype}
  return "No formatters configured!"
end

M.lint = function()
  -- TODO: implement linters (if applicable)
  return "No linters configured!"
end

return M

