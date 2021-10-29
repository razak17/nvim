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

-- Append key mappings to lunarvim's defaults for a given mode
-- @param keymaps The table of key mappings containing a list per mode (normal_mode, insert_mode, ..)
function M.append_to_defaults(keymaps)
  for mode, mappings in pairs(keymaps) do
    for k, v in ipairs(mappings) do
      rvim.keys[mode][k] = v
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

function M.setup()
  local g = vim.g
  g.mapleader = (rvim.common.leader == "space" and " ") or rvim.common.leader
  g.maplocalleader = (rvim.common.localleader == "space" and " ") or rvim.common.localleader
  M.load(rvim.keys)
end

rvim.keys = {
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
  nnoremap = {
    -- Undo
    ["<C-z>"] = ":undo<CR>",

    -- remap esc to use cc
    ["<C-c>"] = "<Esc>",

    -- Better window movement
    ["<C-h>"] = "<C-w>h",
    ["<C-n>"] = "<C-w>j",
    ["<C-k>"] = "<C-w>k",
    ["<C-l>"] = "<C-w>l",

    -- Move current line / block with Alt-j/k a la vscode.
    ["<A-j>"] = ":m .+1<CR>==",
    ["<A-k>"] = ":m .-2<CR>==",

    -- Disable arrows in normal mode
    ["<down>"] = "<nop>",
    ["<up>"] = "<nop>",
    ["<left>"] = "<nop>",
    ["<right>"] = "<nop>",
  },

  ---@usage change or add keymappings for recursive visual block mode
  xnoremap = {
    -- Move selected line / block of text in visual mode
    ["K"] = ":m '<-2<CR>gv=gv",
    ["N"] = ":m '>+1<CR>gv=gv",

    -- Paste in visual mode multiple times
    ["p"] = "pgvy",

    -- Repeat last substitute with flags
    ["&"] = "<cmd>&&<CR>",
  },

  ---@usage change or add keymappings for recursive insert mode
  inoremap = {
    -- Start new line from any cursor position
    ["<S-Return>"] = "<C-o>o",

    -- Disable arrows in insert mode
    ["<down>"] = "<nop>",
    ["<up>"] = "<nop>",
    ["<left>"] = "<nop>",
    ["<right>"] = "<nop>",
  },

  ---@usage change or add keymappings for recursive visual mode
  vnoremap = {
    -- Better indenting
    ["<"] = "<gv",
    [">"] = ">gv",

    -- search visual selection
    ["//"] = [[y/<C-R>"<CR>]],

    -- find visually selected text
    ["*"] = [[y/<C-R>"<CR>]],

    -- make . work with visually selected lines
    ["."] = ":norm.<CR>",

    -- when going to the end of the line in visual mode ignore whitespace characters
    ["$"] = "g_",
  },

  ---@usage change or add keymappings for recursive operator mode
  onoremap = {},

  ---@usage change or add keymappings for recursive terminal mode
  tnoremap = {
    ["<esc>"] = "<C-\\><C-n>:q!<CR>",
    ["jk"] = "<C-\\><C-n>",
    ["<C-h>"] = "<C\\><C-n><C-W>h",
    ["<C-j>"] = "<C-\\><C-n><C-W>j",
    ["<C-k>"] = "<C-\\><C-n><C-W>k",
    ["<C-l>"] = "<C-\\><C-n><C-W>l",
    ["]t"] = "<C-\\><C-n>:tablast<CR>",
    ["[t"] = "<C-\\><C-n>:tabnext<CR>",
    ["<S-Tab>"] = "<C-\\><C-n>:bprev<CR>",
  },

  ---@usage change or add keymappings for recursive select mode
  snoremap = {},

  ---@usage change or add keymappings for recursive command mode
  cnoremap = {
    -- smooth searching, allow tabbing between search results similar to using <c-g>
    -- or <c-t> the main difference being tab is easier to hit and remapping those keys
    -- to these would swallow up a tab mapping
    ["<Tab>"] = { [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>/<C-r>/" : "<C-z>"]], { expr = true } },
    ["<S-Tab>"] = { [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>?<C-r>/" : "<S-Tab>"]], { expr = true } },
  },
}

require "core.keymappings"

return M
