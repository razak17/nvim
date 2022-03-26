-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/plugin/lsp.lua

local lsp = vim.lsp
local fn = vim.fn
local api = vim.api
local fmt = string.format
local L = vim.lsp.log_levels
local icons = rvim.style.icons

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

--- Restricts nvim's diagnostic signs to only the single most severe one per line
--- @see `:help vim.diagnostic`
local ns = api.nvim_create_namespace "severe-diagnostics"

--- Get a reference to the original signs handler
local signs_handler = vim.diagnostic.handlers.signs
--- Override the built-in signs handler
vim.diagnostic.handlers.signs = {
  show = function(_, bufnr, _, opts)
    -- Get all diagnostics from the whole buffer rather than just the
    -- diagnostics passed to the handler
    local diagnostics = vim.diagnostic.get(bufnr)
    -- Find the "worst" diagnostic per line
    local max_severity_per_line = {}
    for _, d in pairs(diagnostics) do
      local m = max_severity_per_line[d.lnum]
      if not m or d.severity < m.severity then
        max_severity_per_line[d.lnum] = d
      end
    end
    -- Pass the filtered diagnostics (with our custom namespace) to
    -- the original handler
    signs_handler.show(ns, bufnr, vim.tbl_values(max_severity_per_line), opts)
  end,
  hide = function(_, bufnr)
    signs_handler.hide(ns, bufnr)
  end,
}

-----------------------------------------------------------------------------//
-- Handler overrides
-----------------------------------------------------------------------------//
local diagnostics = rvim.lsp.diagnostics
vim.diagnostic.config { -- your config
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
}

local max_width = math.max(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.max(math.floor(vim.o.lines * 0.3), 30)

-- NOTE: the hover handler returns the bufnr,winnr so can be used for mappings
lsp.handlers["textDocument/hover"] = lsp.with(
  lsp.handlers.hover,
  { border = "rounded", max_width = max_width, max_height = max_height }
)

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {
  border = "rounded",
  max_width = max_width,
  max_height = max_height,
})

lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local lvl = ({ "ERROR", "WARN", "INFO", "DEBUG" })[result.type]
  vim.notify(result.message, lvl, {
    title = "LSP | " .. client.name,
    timeout = 10000,
    keep = function()
      return lvl == "ERROR" or lvl == "WARN"
    end,
  })
end
