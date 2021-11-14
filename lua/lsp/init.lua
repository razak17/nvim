local M = {}

local Log = require "core.log"
local utils = require "utils"

local function lsp_commands()
  local command = rvim.command

  command {
    "LspLog",
    function()
      vim.cmd("edit " .. vim.lsp.get_log_path())
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
end

local function lsp_hover_diagnostics()
  local get_cursor_pos = function()
    return { vim.fn.line ".", vim.fn.col "." }
  end

  if not rvim.lsp.hover_diagnostics then
    return
  end
  rvim.augroup("HoverDiagnostics", {
    {
      events = { "CursorHold" },
      targets = { "<buffer>" },
      command = (function()
        local cursorpos = get_cursor_pos()
        return function()
          local new_cursor = get_cursor_pos()
          if
            (new_cursor[1] ~= 1 and new_cursor[2] ~= 1)
            and (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2])
          then
            cursorpos = new_cursor
            vim.lsp.diagnostic.show_line_diagnostics { show_header = false, border = "single" }
          end
        end
      end)(),
    },
  })
end

local function lsp_highlight_document(client)
  if rvim.lsp.document_highlight == false then
    return
  end

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

local function lsp_code_lens_refresh(client)
  if rvim.lsp.code_lens_refresh == false then
    return
  end

  if client and client.resolved_capabilities.code_lens then
    rvim.augroup("LspCodeLensRefresh", {
      {
        events = { "InsertLeave" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.codelens.refresh()",
      },
      {
        events = { "InsertLeave" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.codelens.display()",
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

  local status_ok, cmp_nvim_lsp = rvim.safe_require "cmp_nvim_lsp"
  if status_ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
  end

  return capabilities
end

local function select_default_formater(client)
  if client.name == "null-ls" or not client.resolved_capabilities.document_formatting then
    return
  end
  Log:debug("Checking for formatter overriding for " .. client.name)
  local formatters = require "lsp.null-ls.formatters"
  local client_filetypes = client.config.filetypes or {}
  for _, filetype in ipairs(client_filetypes) do
    if #vim.tbl_keys(formatters.list_registered_providers(filetype)) > 0 then
      Log:debug("Formatter overriding detected. Disabling formatting capabilities for " .. client.name)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  end
end

function M.global_on_init(client, bufnr)
  if rvim.lsp.on_init_callback then
    rvim.lsp.on_init_callback(client, bufnr)
    Log:debug "Called lsp.on_init_callback"
    return
  end
  select_default_formater(client)
end

function M.global_on_attach(client, bufnr)
  if rvim.lsp.on_attach_callback then
    rvim.lsp.on_attach_callback(client, bufnr)
    Log:debug "Called lsp.on_attach_callback"
  end
  lsp_highlight_document(client)
  lsp_code_lens_refresh(client)
  lsp_commands()
  lsp_hover_diagnostics()
  require("lsp.binds"):init(client)
end

local function bootstrap_nlsp(opts)
  opts = opts or {}
  local lsp_settings_status_ok, lsp_settings = rvim.safe_require "nlspsettings"
  if lsp_settings_status_ok then
    lsp_settings.setup(opts)
  end
end

function M.get_global_opts()
  return {
    on_attach = M.global_on_attach,
    on_init = M.global_on_init,
    capabilities = M.global_capabilities(),
  }
end

local LSP_DEPRECATED_SIGN_MAP = {
  ["LspDiagnosticsSignError"] = "DiagnosticSignError",
  ["LspDiagnosticsSignWarning"] = "DiagnosticSignWarn",
  ["LspDiagnosticsSignHint"] = "DiagnosticSignHint",
  ["LspDiagnosticsSignInformation"] = "DiagnosticSignInfo",
}

function M.setup()
  Log:debug "Setting up LSP support"

  local lsp_status_ok, _ = rvim.safe_require "lspconfig"
  if not lsp_status_ok then
    return
  end

  local is_neovim_nightly = vim.fn.has "nvim-0.5.1" > 0

  for _, sign in ipairs(rvim.lsp.diagnostics.signs.values) do
    local lsp_sign_name = LSP_DEPRECATED_SIGN_MAP[sign.name]
    if is_neovim_nightly and lsp_sign_name then
      vim.fn.sign_define(lsp_sign_name, { texthl = lsp_sign_name, text = sign.text, numhl = lsp_sign_name })
    end
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  require("lsp.handlers").setup()

  bootstrap_nlsp { config_home = utils.join_paths(get_config_dir(), "external/nlsp-settings") }

  require("lsp.null-ls").setup(vim.bo.filetype)

  require("lsp.utils").toggle_autoformat()
end

return M
