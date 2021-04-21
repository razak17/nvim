local utils = require 'internal.utils'

require 'modules.lsp.lspconfig.config'

utils.global_cmd("LspLog", "open_lsp_log")
utils.global_cmd("LspRestart", "reload_lsp")
utils.global_cmd("LspToggleVirtualText", "lsp_toggle_virtual_text")

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = true,
      update_in_insert = true,
      virtual_text = {spacing = 4},
      signs = {enable = true, priority = 20}
    })

require'modules.lsp.servers'.setup()
