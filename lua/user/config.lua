----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------
local env = vim.env

local namespace = {
  ai = { enable = env.RVIM_AI_ENABLED == '1' },
  debug = { enable = false },
  autosave = { enable = true },
  lsp = {
    enable = env.RVIM_LSP_ENABLED == '1' and env.RVIM_PLUGINS_MINIMAL == '0',
    disabled = {
      filetypes = {},
      directories = { vim.fn.stdpath('data') },
      servers = { 'emmet_ls' },
    },
    format_on_save = { enable = true },
    signs = { enable = false },
    hover_diagnostics = { enable = true, scope = 'cursor' },
  },
  mappings = {},
  minimal = env.RVIM_LSP_ENABLED == '0' or env.RVIM_PLUGINS_ENABLED == '0' or env.RVIM_NONE == '1',
  none = env.RVIM_NONE == '1',
  plugins = {
    enable = env.RVIM_PLUGINS_ENABLED == '1',
    disabled = {},
    minimal = env.RVIM_PLUGINS_MINIMAL == '1',
  },
  treesitter = { enable = true },
  ui = {
    statuscolumn = { enable = true },
  },
}

_G.rvim = rvim or namespace
_G.map = vim.keymap.set
