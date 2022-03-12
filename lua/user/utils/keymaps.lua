local M = {}

rvim.keymaps = {
  ---@usage change or add keymappings for normal mode
  nmap = {},

  ---@usage change or add keymappings for visual block mode
  xmap = {},

  ---@usage change or add keymappings for insert mode
  imap = {},

  ---@usage change or add keymappings for visual mode
  vmap = {},

  ---@usage change or add keymappings for operator mode
  omap = {},

  ---@usage change or add keymappings for terminal mode
  tmap = {},

  ---@usage change or add keymappings for select mode
  smap = {},

  ---@usage change or add keymappings for command mode
  cmap = {},

  ---@usage change or add keymappings for recursive normal mode
  nnoremap = {},

  ---@usage change or add keymappings for recursive visual block mode
  xnoremap = {},

  ---@usage change or add keymappings for recursive insert mode
  inoremap = {},

  ---@usage change or add keymappings for recursive visual mode
  vnoremap = {},

  ---@usage change or add keymappings for recursive operator mode
  onoremap = {},

  ---@usage change or add keymappings for recursive terminal mode
  tnoremap = {},

  ---@usage change or add keymappings for recursive select mode
  snoremap = {},

  ---@usage change or add keymappings for recursive command mode
  cnoremap = {},
}

local map_opts = { noremap = false, silent = true }
local noremap_opts = { noremap = true, silent = true }

local generic_opts = {
  nmap = map_opts,
  xmap = map_opts,
  imap = map_opts,
  vmap = map_opts,
  omap = map_opts,
  tmap = map_opts,
  smap = map_opts,
  cmap = { noremap = false, silent = false },
  nnoremap = noremap_opts,
  xnoremap = noremap_opts,
  inoremap = noremap_opts,
  vnoremap = noremap_opts,
  onoremap = noremap_opts,
  tnoremap = noremap_opts,
  snoremap = noremap_opts,
  cnoremap = { noremap = true, silent = false },
}

local mode_adapters = {
  nmap = "n",
  xmap = "x",
  imap = "i",
  vmap = "v",
  omap = "o",
  tmap = "t",
  smap = "s",
  cmap = "c",
  nnoremap = "n",
  xnoremap = "x",
  inoremap = "i",
  vnoremap = "v",
  onoremap = "o",
  tnoremap = "t",
  snoremap = "s",
  cnoremap = "c",
}

-- Set key mappings individually
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param key The key of keymap
-- @param val Can be form as a mapping or tuple of mapping and user defined opt
function M.set_keymaps(mode, key, val)
  local opt = generic_opts[mode]
  if type(val) == "table" then
    opt = val[2]
    val = val[1]
  end

  if type(val) == "function" then
    local fn_id = rvim._create(val)
    val = string.format("<cmd>lua rvim._execute(%s)<CR>", fn_id)
  end

  vim.api.nvim_set_keymap(mode_adapters[mode], key, val, opt)
  -- vim.keymap.set(mode_adapters[mode], key, val, opt)
end

-- Load key mappings for a given mode
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param keymaps The list of key mappings
function M.load_mode(mode, keymaps)
  for k, v in pairs(keymaps) do
    M.set_keymaps(mode, k, v)
  end
end

-- Load key mappings for all provided modes
-- @param keymaps A list of key mappings for each mode
function M.load(keymaps)
  for mode, mapping in pairs(keymaps) do
    M.load_mode(mode, mapping)
  end
end

function M:init()
  local g = vim.g
  g.mapleader = (rvim.common.leader == "space" and " ") or rvim.common.leader
  g.maplocalleader = (rvim.common.localleader == "space" and " ") or rvim.common.localleader
  M.load(rvim.keymaps)
end

return M
