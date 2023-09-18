--------------------------------------------------------------------------------
-- Global namespace
--------------------------------------------------------------------------------
local env = vim.env

local namespace = {
  ai = { enable = env.RVIM_AI_ENABLED == '1' },
  debug = { enable = false },
  autosave = { enable = true },
  lsp = {
    enable = env.RVIM_LSP_ENABLED == '1' and env.RVIM_PLUGINS_MINIMAL == '0',
    override = {},
    disabled = {
      filetypes = {},
      directories = { vim.fn.stdpath('data') },
      servers = { 'emmet_ls' },
    },
    format_on_save = { enable = true },
    signs = { enable = false },
    hover_diagnostics = { enable = true, scope = 'cursor' },
    null_ls = { enable = true },
  },
  mappings = {},
  git = {},
  none = env.RVIM_NONE == '1',
  plugins = {
    enable = env.RVIM_PLUGINS_ENABLED == '1',
    disabled = {},
    minimal = env.RVIM_PLUGINS_MINIMAL == '1',
    overrides = {
      ghost_text = { enable = env.RVIM_GHOST_ENABLED == '1' },
      copilot_cmp = { enable = false },
    },
  },
  treesitter = {
    enable = env.RVIM_PLUGINS_MINIMAL == '0'
      and env.RVIM_TREESITTER_ENABLED == '1',
  },
  ui = {
    statuscolumn = { enable = true },
  },
}

_G.rvim = rvim or namespace
_G.map = vim.keymap.set
