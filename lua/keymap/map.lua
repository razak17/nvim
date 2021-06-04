require("core.globals.utils")

local api = vim.api
--
---check if a mapping already exists
---@param lhs string
---@param mode string
---@return boolean
local function has_map(lhs, mode)
  mode = mode or "n"
  return vim.fn.maparg(lhs, mode) ~= ""
end

local function validate_opts(opts)
  if not opts then
    return true
  end

  if type(opts) ~= "table" then
    return false, "opts should be a table"
  end

  if opts.buffer and type(opts.buffer) ~= "number" then
    return false, "The buffer key should be a number"
  end

  return true
end

local function validate_mappings(lhs, rhs, opts)
  vim.validate {
    lhs = {lhs, "string"},
    rhs = {
      rhs,
      function(a)
        local arg_type = type(a)
        return arg_type == "string" or arg_type == "function"
      end,
      "right hand side"
    },
    opts = {opts, validate_opts, "mapping options are incorrect"}
  }
end

---create a mapping function factory
---@param mode string
---@param o table
---@return function
local function make_mapper(mode, o)
  -- copy the opts table as extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(o)
  ---Create a mapping
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts table
  return function(lhs, rhs, opts)
    -- assert(lhs ~= mode,
    --        fmt("The lhs should not be the same as mode for %s", lhs))
    local _opts = opts and vim.deepcopy(opts) or {}

    validate_mappings(lhs, rhs, _opts)

    if _opts.check_existing and has_map(lhs) then
      return
    else
      -- don't pass this invalid key to set keymap
      _opts.check_existing = nil
    end

    -- add functions to a global table keyed by their index
    if type(rhs) == "function" then
      local fn_id = r17._create(rhs)
      rhs = string.format("<cmd>lua r17._execute(%s)<CR>", fn_id)
    end

    if _opts.buffer then
      -- Remove the buffer from the args sent to the key map function
      local bufnr = _opts.buffer
      _opts.buffer = nil
      _opts = vim.tbl_extend("keep", _opts, parent_opts)
      api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, _opts)
    else
      api.nvim_set_keymap(mode, lhs, rhs,
                          vim.tbl_extend("keep", _opts, parent_opts))
    end
  end
end

local map_opts = {noremap = false, silent = true}
r17.map = make_mapper("", map_opts)
r17.nmap = make_mapper("n", map_opts)
r17.xmap = make_mapper("x", map_opts)
r17.imap = make_mapper("i", map_opts)
r17.vmap = make_mapper("v", map_opts)
r17.omap = make_mapper("o", map_opts)
r17.tmap = make_mapper("t", map_opts)
r17.smap = make_mapper("s", map_opts)
r17.cmap = make_mapper("c", {noremap = false, silent = false})

local noremap_opts = {noremap = true, silent = true}
r17.nnoremap = make_mapper("n", noremap_opts)
r17.xnoremap = make_mapper("x", noremap_opts)
r17.vnoremap = make_mapper("v", noremap_opts)
r17.inoremap = make_mapper("i", noremap_opts)
r17.onoremap = make_mapper("o", noremap_opts)
r17.tnoremap = make_mapper("t", noremap_opts)
r17.snoremap = make_mapper("s", noremap_opts)
r17.cnoremap = make_mapper("c", {noremap = true, silent = false})

return r17
