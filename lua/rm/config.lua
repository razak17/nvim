--------------------------------------------------------------------------------
-- Global namespace
--------------------------------------------------------------------------------
local env = vim.env

local namespace = {
  ai = { enable = env.RVIM_AI_ENABLED == '1' },
  autosave = { enable = true },
  debug = { enable = false },
  large_file_opened = false,
  -- stylua: ignore
  media_files = {
    'jpg', 'png', 'jpeg', 'ico', 'gif', 'pdf', 'mp3', 'm4a', 'mp4', 'mkv',
  },
  lsp = {
    disabled = {
      filetypes = {},
      directories = { vim.fn.stdpath('data') },
      servers = { 'emmet_ls' },
    },
    enable = env.RVIM_LSP_ENABLED == '1' and env.RVIM_PLUGINS_MINIMAL == '0',
    format_on_save = { enable = true },
    hover_diagnostics = { enable = false, go_to = false, scope = 'cursor' },
    null_ls = { enable = false },
    omnifunc = { enable = true },
    override = {},
    progress = { enable = true },
    signs = { enable = false },
  },
  mappings = {},
  git = {},
  none = env.RVIM_NONE == '1',
  plugin = {
    env = { enable = true },
    interceptor = { enable = true },
    large_file = { enable = true },
    notepad = { enable = false },
    smart_splits = { enable = true },
    smart_tilde = { enable = true },
    sticky_note = { enable = false },
    tmux = { enable = true },
    ui_select = { enable = true },
    whitespace = { enable = env.RVIM_PLUGINS_MINIMAL == '1' },
  },
  plugins = {
    enable = env.RVIM_PLUGINS_ENABLED == '1',
    disabled = {},
    minimal = env.RVIM_PLUGINS_MINIMAL == '1',
    niceties = env.RVIM_NICETIES_ENABLED == '1',
    overrides = {
      dict = { enable = env.RVIM_DICT_ENABLED == '1' },
      ghost_text = { enable = env.RVIM_GHOST_ENABLED == '1' },
      copilot_cmp = { enable = false },
      codeium = { enable = false },
      garbage_day = { enable = false },
    },
  },
  completion = {
    enable = env.RVIM_COMPLETION_ENABLED == '1',
  },
  treesitter = {
    enable = env.RVIM_PLUGINS_MINIMAL == '0'
      and env.RVIM_TREESITTER_ENABLED == '1',
  },
  ui = {
    statuscolumn = { enable = true, custom = true },
  },
}

_G.rvim = rvim or namespace
_G.map = vim.keymap.set
