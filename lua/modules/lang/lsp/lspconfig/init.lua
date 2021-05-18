local global_cmd = require'internal.utils'.global_cmd
local utils = require 'internal.utils'

function _G.open_lsp_log()
  local path = vim.lsp.get_log_path()
  vim.cmd("edit " .. path)
end

function _G.reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  vim.cmd [[edit]]
end

function _G.lsp_formatting()
  vim.lsp.buf.formatting(vim.g[string.format("format_options_%s",
                                             vim.bo.filetype)] or {})
end

function _G.lsp_toggle_virtual_text()
  local virtual_text = {}
  virtual_text.show = true
  virtual_text.show = not virtual_text.show
  vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1,
                             {virtual_text = virtual_text.show})
end

function _G.lsp_before_save()
  local defs = {}
  local ext = vim.fn.expand('%:e')
  table.insert(defs, {
    "BufWritePre",
    '*.' .. ext,
    "lua vim.lsp.buf.formatting_sync(nil,1000)"
  })
  utils.nvim_create_augroup('lsp_before_save', defs)
end

global_cmd("LspLog", "open_lsp_log")
global_cmd("LspRestart", "reload_lsp")
global_cmd("LspToggleVirtualText", "lsp_toggle_virtual_text")
global_cmd("LspBeforeSave", "lsp_before_save")

-- symbols for autocomplete
vim.lsp.protocol.CompletionItemKind = {
  "   (Text) ",
  "   (Method)",
  "   (Function)",
  "   (Constructor)",
  " ﴲ  (Field)",
  "   (Variable)",
  "   (Class)",
  " ﰮ  (Interface)",
  "   (Module)",
  " 襁 (Property)",
  "   (Unit)",
  "   (Value)",
  " 練 (Enum)",
  "   (Keyword)",
  "   (Snippet)",
  "   (Color)",
  "   (File)",
  "   (Reference)",
  "   (Folder)",
  "   (EnumMember)",
  " ﲀ  (Constant)",
  " ﳤ  (Struct)",
  "   (Event)",
  "   (Operator)",
  "   (TypeParameter)"
}

require'modules.lang.lsp.servers'.setup()
