local M = {}

M.init = function()
  if core.check_lsp_client_active "cssls" then
    return
  end
  require'lspconfig'.cssls.setup {
    cmd = {core.lsp.binary.css, "--stdio"},
    capabilities = core.lsp.capabilities,
    on_attach = core.lsp.on_attach,
    root_dir = require'lspconfig.util'.root_pattern('.gitignore', '.git', vim.fn.getcwd()),
  }
end

M.format = function()
  local filetype = {}
  local ft = vim.bo.filetype
  filetype[ft] = {
    function()
      local args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))}
      local extend_args = {}
      for i = 1, #extend_args do
        table.insert(args, extend_args[i])
      end
      return {exe = "prettier", args = args, stdin = true}
    end,
  }
  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.lint = function()
  -- TODO: implement linters (if applicable)
  return "No linters configured!"
end

return M

