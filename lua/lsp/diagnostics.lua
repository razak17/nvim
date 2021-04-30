local vim = vim
local M = {}
local mapk = vim.api.nvim_buf_set_keymap;

function M.setup(bufnr, opts)
  -- diagnostics-lsp
  -- indicator_ok = '',
  vim.fn.sign_define("LspDiagnosticsSignError", {text = "", texthl = "LspDiagnosticsError"})
  vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "", texthl = "LspDiagnosticsSignWarning"})
  vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "🛈", texthl = "LspDiagnosticsSignInformation"})
  vim.fn.sign_define("LspDiagnosticsSignHint", {text = "!", texthl = "LspDiagnosticsSignHint"})
  mapk(bufnr, 'n', '<Leader>vlo', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  mapk(bufnr, 'n', '<Leader>vde',  '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  mapk(bufnr, 'n', '<Leader>vdn',  '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
end

function M.handlers()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = true,
      virtual_text = {
        spacing = 4,
        -- prefix = '',
      },
      signs = function(bufnr, client_id)
        local ok, result = pcall(vim.api.nvim_buf_get_var, bufnr, 'show_signs')
        if not ok then
          return true
        end
        return result
      end,
      update_in_insert = false,
    }
  )
end

return M

