local M = {}

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

-- Append key mappings to rvim's defaults for a given mode
-- @param keymaps The table of key mappings containing a list per mode (normal_mode, insert_mode, ..)
function M.append_to_defaults(keymaps)
  for mode, mappings in pairs(keymaps) do
    for k, v in ipairs(mappings) do
      defaults[mode][k] = v
    end
  end
end

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

function M:init(keymaps)
  local g = vim.g
  g.mapleader = (rvim.common.leader == "space" and " ") or rvim.common.leader
  g.maplocalleader = (rvim.common.localleader == "space" and " ") or rvim.common.localleader
  M.load(keymaps)
end

return M
