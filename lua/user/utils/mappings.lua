-----------------------------------------------------------------------------//
-- MAPPINGS
-----------------------------------------------------------------------------//

---create a mapping function factory
---@param mode string
---@param o table
---@return fun(lhs: string, rhs: string, opts: table|nil) 'create a mapping'
local function make_mapper(mode, o)
  -- copy the opts table rvim extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(o)
  ---Create a mapping
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts table
  return function(lhs, rhs, opts)
    -- If the label is all that was passed in, set the opts automagically
    opts = type(opts) == "string" and { label = opts } or opts and vim.deepcopy(opts) or {}
    if opts.label then
      local ok, wk = rvim.safe_require("which-key", { silent = true })
      if ok then
        wk.register({ [lhs] = opts.label }, { mode = mode })
      end
      opts.label = nil
    end
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("keep", opts, parent_opts))
  end
end

local map_opts = { remap = true, silent = true }
local noremap_opts = { silent = true }

-- A recursive commandline mapping
rvim.nmap = make_mapper("n", map_opts)
-- A recursive select mapping
rvim.xmap = make_mapper("x", map_opts)
-- A recursive terminal mapping
rvim.imap = make_mapper("i", map_opts)
-- A recursive operator mapping
rvim.vmap = make_mapper("v", map_opts)
-- A recursive insert mapping
rvim.omap = make_mapper("o", map_opts)
-- A recursive visual & select mapping
rvim.tmap = make_mapper("t", map_opts)
-- A recursive visual mapping
rvim.smap = make_mapper("s", map_opts) -- A recursive normal mapping
rvim.cmap = make_mapper("c", { remap = false, silent = false })
-- A non recursive normal mapping
rvim.nnoremap = make_mapper("n", noremap_opts)
-- A non recursive visual mapping
rvim.xnoremap = make_mapper("x", noremap_opts)
-- A non recursive visual & select mapping
rvim.vnoremap = make_mapper("v", noremap_opts)
-- A non recursive insert mapping
rvim.inoremap = make_mapper("i", noremap_opts)
-- A non recursive operator mapping
rvim.onoremap = make_mapper("o", noremap_opts)
-- A non recursive terminal mapping
rvim.tnoremap = make_mapper("t", noremap_opts)
-- A non recursive select mapping
rvim.snoremap = make_mapper("s", noremap_opts)
-- A non recursive commandline mapping
rvim.cnoremap = make_mapper("c", { silent = false })
