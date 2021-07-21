local M = {}

M.init = function()
  require'lspconfig'.jsonls.setup {
    cmd = {core.lsp.binary.json, "--stdio"},
    capabilities = core.lsp.capabilities,
    on_attach = core.lsp.on_attach,
    root_dir = require'lspconfig.util'.root_pattern('.gitignore', '.git', vim.fn.getcwd()),
  }
end

M.format = function()
  local filetype = {}
  filetype["json"] = {
    function()
      return {exe = "python", args = {"-m", "json.tool"}, stdin = true}
    end,
  }

  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.lint = function()
  -- TODO: implement linters (if applicable)
  return "No linters configured!"
end

return M
