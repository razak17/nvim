local lspconfig = require "lspconfig"
local command = rvim.command
local Log = require "core.log"

local M = {}

function M.config()
  vim.lsp.protocol.CompletionItemKind = rvim.lsp.completion.item_kind

  for _, sign in ipairs(rvim.lsp.diagnostics.signs.values) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  command {
    "LspLog",
    function()
      local path = vim.lsp.get_log_path()
      vim.cmd("edit " .. path)
    end,
  }
  command {
    "LspFormat",
    function()
      vim.lsp.buf.formatting(vim.g[string.format("format_options_%s", vim.bo.filetype)] or {})
    end,
  }
  command {
    "LspToggleVirtualText",
    function()
      local virtual_text = {}
      virtual_text.show = true
      virtual_text.show = not virtual_text.show
      vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1, { virtual_text = virtual_text.show })
    end,
  }
  command {
    "LspReload",
    function()
      vim.cmd [[
      :lua vim.lsp.stop_client(vim.lsp.get_active_clients())
      :edit
    ]]
    end,
  }

  require("lsp.hover").setup()
  require("lsp.handlers").setup()
end

local function lsp_highlight_document(client)
  if client and client.resolved_capabilities.document_highlight then
    rvim.augroup("LspCursorCommands", {
      {
        events = { "CursorHold" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.buf.document_highlight()",
      },
      {
        events = { "CursorHoldI" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.buf.document_highlight()",
      },
      {
        events = { "CursorMoved" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.buf.clear_references()",
      },
    })
  end
end

function M.global_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  capabilities.textDocument.codeAction = {
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
  return capabilities
end

function M.global_on_init(client, bufnr)
  local formatters = rvim.lang[vim.bo.filetype].formatters
  if not vim.tbl_isempty(formatters) and formatters[1]["exe"] ~= nil and formatters[1].exe ~= "" then
    client.resolved_capabilities.document_formatting = false
    Log:get_default().info(
      string.format("Overriding language server [%s] with format provider [%s]", client.name, formatters[1].exe)
    )
  end
end

function M.global_on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  lsp_highlight_document(client)
  require("lsp.binds").setup(client)
  require("lsp.null-ls").setup(vim.bo.filetype)
end

function M.setup(lang)
  lspconfig.util.default_config = vim.tbl_extend(
    "force",
    lspconfig.util.default_config,
    { capabilities = M.global_capabilities(), on_init = M.global_on_init() }
  )

  local lsp_utils = require "lsp.utils"
  local lsp = rvim.lang[lang].lsp
  if lsp_utils.is_client_active(lsp.provider) then
    return
  end

  if lsp.provider ~= nil and lsp.provider ~= "" then
    if not lsp.setup.on_attach then
      lsp.setup.on_attach = M.global_on_attach
    end
    if not lsp.setup.on_init then
      lsp.setup.on_init = M.global_on_init
    end
    if not lsp.setup.capabilities then
      lsp.setup.capabilities = M.common_capabilities()
    end
    lspconfig[lsp.provider].setup(lsp.setup)
  end
end

return M
