local api = vim.api

---check if a mapping already exists
---@param lhs string
---@param mode string
---@return boolean
function rvim.has_map(lhs, mode)
  mode = mode or "n"
  return vim.fn.maparg(lhs, mode) ~= ""
end

---create a mapping function factory
---@param mode string
---@param o table
---@return fun(lhs: string, rhs: string, opts: table|nil) 'create a mapping'
local function make_mapper(mode, o)
  -- copy the opts table as extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(o)
  ---Create a mapping
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts table
  return function(lhs, rhs, opts)
    -- assert(lhs ~= mode, fmt("The lhs should not be the same as mode for %s", lhs))
    assert(type(rhs) == "string" or type(rhs) == "function", '"rhs" should be a function or string')
    opts = opts and vim.deepcopy(opts) or {}

    local buffer = opts.buffer
    -- don't pass invalid keys to set keymap
    opts.buffer = nil
    -- add functions to a global table keyed by their index
    if type(rhs) == "function" then
      local fn_id = rvim._create(rhs)
      rhs = string.format("<cmd>lua rvim._execute(%s)<CR>", fn_id)
    end

    if buffer and type(buffer) == "number" then
      opts = vim.tbl_extend("keep", opts, parent_opts)
      api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, opts)
    elseif not buffer then
      api.nvim_set_keymap(mode, lhs, rhs, vim.tbl_extend("keep", opts, parent_opts))
    end
  end
end

rvim.make_mapper = make_mapper

local map_opts = { noremap = false, silent = true }
local noremap_opts = { noremap = true, silent = true }

-- A recursive commandline mapping
rvim.nmap = make_mapper('n', map_opts)
-- A recursive select mapping
rvim.xmap = make_mapper('x', map_opts)
-- A recursive visual & select mapping
rvim.imap = make_mapper('i', map_opts)
-- A recursive insert mapping
rvim.vmap = make_mapper('v', map_opts)
-- A recursive visual mapping
rvim.omap = make_mapper('o', map_opts)
-- A recursive operator mapping
rvim.tmap = make_mapper('t', map_opts)
-- A recursive terminal mapping
rvim.smap = make_mapper('s', map_opts)
-- A recursive normal mapping
rvim.cmap = make_mapper('c', { noremap = false, silent = false })
-- A non recursive normal mapping
rvim.nnoremap = make_mapper('n', noremap_opts)
-- A non recursive visual & select mapping
rvim.xnoremap = make_mapper('x', noremap_opts)
-- A non recursive visual mapping
rvim.vnoremap = make_mapper('v', noremap_opts)
-- A non recursive insert mapping
rvim.inoremap = make_mapper('i', noremap_opts)
-- A non recursive operator mapping
rvim.onoremap = make_mapper('o', noremap_opts)
-- A non recursive terminal mapping
rvim.tnoremap = make_mapper('t', noremap_opts)
-- A non recursive select mapping
rvim.snoremap = make_mapper('s', noremap_opts)
-- A non recursive commandline mapping
rvim.cnoremap = make_mapper('c', { noremap = true, silent = false })

---Factory function to create multi mode map functions
---e.g. `as.map({"n", "s"}, lhs, rhs, opts)`
---@param target string
---@return fun(modes: string[], lhs: string, rhs: string, opts: table)
local function multimap(target)
  return function(modes, lhs, rhs, opts)
    for _, m in ipairs(modes) do
      rvim[m .. target](lhs, rhs, opts)
    end
  end
end

rvim.map = multimap 'map'
rvim.noremap = multimap 'noremap'
