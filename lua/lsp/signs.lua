local M = {}

function M.init()
  vim.fn.sign_define {
    { name = "LspDiagnosticsSignError", text = rvim.style.icons.error, texthl = "LspDiagnosticsSignError" },
    { name = "LspDiagnosticsSignHint", text = rvim.style.icons.hint, texthl = "LspDiagnosticsSignHint" },
    { name = "LspDiagnosticsSignWarning", text = rvim.style.icons.warning, texthl = "LspDiagnosticsSignWarning" },
    { name = "LspDiagnosticsSignInformation", text = rvim.style.icons.info, texthl = "LspDiagnosticsSignInformation" },
  }
end

return M
