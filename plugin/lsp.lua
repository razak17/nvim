-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/plugin/lsp.lua

local lsp = vim.lsp
local fn = vim.fn
local api = vim.api
local fmt = string.format
local L = vim.lsp.log_levels
local icons = rvim.style.icons
local border = rvim.style.border.current
local AUGROUP = "LspCommands"

if vim.env.DEVELOPING then
  vim.lsp.set_log_level(L.DEBUG)
end

-----------------------------------------------------------------------------//
-- Autocommands
-----------------------------------------------------------------------------//

-- Show the popup diagnostics window, but only once for the current cursor location
-- by checking whether the word under the cursor has changed.
local function diagnostic_popup()
  local cword = vim.fn.expand("<cword>")
  if cword ~= vim.w.lsp_diagnostics_cword then
    vim.w.lsp_diagnostics_cword = cword
    vim.diagnostic.open_float(0, { scope = "cursor", focus = false })
  end
end

--- Add lsp autocommands
---@param client table<string, any>
---@param bufnr number
local function setup_autocommands(client, bufnr)
  local cmds = {}
  if not client then
    local msg = fmt("Unable to setup LSP autocommands, client for %d is missing", bufnr)
    return vim.notify(msg, "error", { title = "LSP Setup" })
  end
  if client.server_capabilities.documentFormattingProvider then
    -- Format On Save
    local opts = rvim.util.format_on_save
    if rvim.find_string(rvim.lsp.format_on_save_exclusions, vim.bo.ft) then
      return
    end
    table.insert(cmds, {
      event = { "BufWritePre" },
      pattern = { opts.pattern },
      desc = "Format the current buffer on save",
      command = function()
        require("user.utils.lsp").format({ timeout_ms = opts.timeout, filter = opts.filter })
      end,
    })
  end
  if client.server_capabilities.codeLensProvider then
    if rvim.lsp.code_lens_refresh then
      -- Code Lens
      table.insert(cmds, {
        event = { "BufEnter", "CursorHold", "InsertLeave" },
        buffer = bufnr,
        command = function()
          vim.lsp.codelens.refresh()
        end,
      })
    end
  end
  if client.server_capabilities.documentHighlightProvider then
    if rvim.lsp.hover_diagnostics then
      -- Hover Diagnostics
      table.insert(cmds, {
        event = { "CursorHold" },
        buffer = bufnr,
        desc = "Show diagnostics on hover",
        command = function()
          diagnostic_popup()
        end,
      })
    end
    if rvim.lsp.document_highlight then
      -- Cursor Commands
      table.insert(cmds, {
        event = { "CursorHold", "CursorHoldI" },
        buffer = bufnr,
        desc = "LSP: Document Highlight",
        command = function()
          vim.lsp.buf.document_highlight()
        end,
      })
      table.insert(cmds, {
        event = { "CursorMoved" },
        desc = "LSP: Document Highlight (Clear)",
        buffer = bufnr,
        command = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end
  rvim.augroup(AUGROUP, cmds)
end

-----------------------------------------------------------------------------//
-- LSP SETUP/TEARDOWN
-----------------------------------------------------------------------------//

function setup_plugins(client, bufnr)
  -- vim-illuminate
  if rvim.lsp.document_highlight then
    local status_ok, illuminate = rvim.safe_require("illuminate")
    if not status_ok then
      return
    end
    illuminate.on_attach(client)
  end
  -- nvim-navic
  local ok, navic = pcall(require, "nvim-navic")
  if ok and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
end

---Add buffer local mappings, autocommands, tagfunc etc for attaching servers
---@param client table lsp client
---@param bufnr number
function rvim.lsp.on_attach(client, bufnr)
  local keymaps = require("user.lsp.keymaps")
  setup_autocommands(client, bufnr)
  setup_plugins(client, bufnr)
  keymaps.init(client)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
  if client.server_capabilities.definitionProvider then
    vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
  end

  if client.server_capabilities.documentFormattingProvider then
    vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
  end
end

rvim.augroup("LspSetupCommands", {
  {
    event = 'LspAttach',
    desc = 'setup the language server autocommands',
    command = function(args)
      local bufnr = args.buf
      -- if the buffer is invalid we should not try and attach to it
      if not api.nvim_buf_is_valid(args.buf) or not args.data then
        return
      end
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      rvim.lsp.on_attach(client, bufnr)
    end,
  },
  {
    event = "LspDetach",
    desc = "Clean up after detached LSP",
    command = function(args)
      api.nvim_clear_autocmds({ group = AUGROUP, buffer = args.buf })
    end,
  },
})

-----------------------------------------------------------------------------//
-- Signs
-----------------------------------------------------------------------------//
local diagnostic_types = {
  { "Error", icon = icons.lsp.error },
  { "Warn", icon = icons.lsp.warn },
  { "Info", icon = icons.lsp.info },
  { "Hint", icon = icons.lsp.hint },
}

fn.sign_define(vim.tbl_map(function(t)
  local hl = "DiagnosticSign" .. t[1]
  return {
    name = hl,
    text = t.icon,
    texthl = hl,
    linehl = fmt("%sLine", hl),
  }
end, diagnostic_types))

-----------------------------------------------------------------------------//
-- Handler overrides
-----------------------------------------------------------------------------//
local diagnostics = rvim.lsp.diagnostics
vim.diagnostic.config({ -- your config
  virtual_text = {
    source = "if_many",
    prefix = icons.misc.bug,
    spacing = diagnostics.virtual_text_spacing,
  },
  signs = { active = diagnostics.signs.active, values = icons.lsp },
  underline = diagnostics.underline,
  update_in_insert = diagnostics.update_in_insert,
  severity_sort = diagnostics.severity_sort,
  float = diagnostics.float,
})

local max_width = math.min(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.min(math.floor(vim.o.lines * 0.3), 30)

-- NOTE: the hover handler returns the bufnr,winnr so can be used for mappings
lsp.handlers["textDocument/hover"] = lsp.with(
  lsp.handlers.hover,
  { border = border, max_width = max_width, max_height = max_height }
)

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {
  border = border,
  max_width = max_width,
  max_height = max_height,
})

lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local lvl = ({ "ERROR", "WARN", "INFO", "DEBUG" })[result.type]
  vim.notify(result.message, lvl, {
    title = "LSP | " .. client.name,
    timeout = 8000,
    keep = function()
      return lvl == "ERROR" or lvl == "WARN"
    end,
  })
end
