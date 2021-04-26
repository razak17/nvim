local global_cmd = require'internal.utils'.global_cmd

require 'modules.lsp.lspconfig.config'

global_cmd("LspLog", "open_lsp_log")
global_cmd("LspRestart", "reload_lsp")
global_cmd("LspToggleVirtualText", "lsp_toggle_virtual_text")

require'modules.lsp.servers'.setup()
