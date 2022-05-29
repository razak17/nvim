-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/plugin/lsp.lua

local lsp = vim.lsp
local fn = vim.fn
local fmt = string.format
local L = vim.lsp.log_levels
local icons = rvim.style.icons
local border = rvim.style.border.current

if vim.env.DEVELOPING then
  vim.lsp.set_log_level(L.DEBUG)
end

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
