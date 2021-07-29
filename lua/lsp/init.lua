local lspconfig = require "lspconfig"
local lsp_utils = require "lsp.utils"
local service = require "lsp.service"

local M = {}
local is_table = lsp_utils.is_table
local is_string = lsp_utils.is_string
local has_value = lsp_utils.has_value

local global_capabilities = vim.lsp.protocol.make_client_capabilities()
global_capabilities.textDocument.completion.completionItem.snippetSupport = true
global_capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}
global_capabilities.textDocument.codeAction = {
  dynamicRegistration = false,
  codeActionLiteralSupport = {
    codeActionKind = {
      valueSet = (function()
        local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
        table.sort(res)
        return res
      end)(),
    },
  },
}

lspconfig.util.default_config = vim.tbl_extend(
  "force",
  lspconfig.util.default_config,
  { capabilities = global_capabilities }
)

function M.init()
  require("lsp.kind").init()
  require("lsp.signs").init()
  require("lsp.hover").init()
  require("lsp.binds").init()
  require("lsp.handlers").init()
  require("lsp.commands").init()
  require("lsp.servers").init()
  lsp_utils.toggle_autoformat()
  lsp_utils.lspLocList()
end

function M.setup(lang)
  local lang_server = rvim.lang[lang].lsp
  local provider = lang_server.provider
  if lsp_utils.check_lsp_client_active(provider) then
    return
  end

  local overrides = rvim.lsp.override

  if is_table(overrides) then
    if has_value(overrides, lang) then
      return
    end
  end

  if is_string(overrides) then
    if overrides == lang then
      return
    end
  end
  local sources = require("lsp.null-ls").setup(lang)

  for _, source in pairs(sources) do
    local method = source.method
    local format_method = "NULL_LS_FORMATTING"

    if is_table(method) then
      if has_value(method, format_method) then
        lang_server.setup.on_attach = service.no_formatter_on_attach
      end
    end

    if is_string(method) then
      if method == format_method then
        lang_server.setup.on_attach = service.no_formatter_on_attach
      end
    end
  end

  if provider == "" or provider == nil then
    return
  end

  require("lspconfig")[provider].setup(lang_server.setup)
end

return M
