local api = vim.api
local fmt = string.format

local M = {}

---@class HighlightAttributes
---@field from string
---@field attr 'foreground' | 'fg' | 'background' | 'bg'
---@field alter integer

---@class HighlightKeys
---@field blend integer
---@field foreground string | HighlightAttributes
---@field background string | HighlightAttributes
---@field fg string | HighlightAttributes
---@field bg string | HighlightAttributes
---@field sp string | HighlightAttributes
---@field bold boolean
---@field italic boolean
---@field undercurl boolean
---@field underline boolean
---@field underdot boolean

---Convert a hex color to RGB
---@param color string
---@return number
---@return number
---@return number
local function hex_to_rgb(color)
  local hex = color:gsub('#', '')
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5), 16)
end

local function alter(attribute, percent) return math.floor(attribute * (100 + percent) / 100) end

---@source https://stackoverflow.com/q/5560248
---@see: https://stackoverflow.com/a/37797380
---Darken a specified hex color
---@param color string A hex color
---@param percent integer a negative number darkens and a positive one brightens
function M.alter_color(color, percent)
  local r, g, b = hex_to_rgb(color)
  if not r or not g or not b then return 'NONE' end
  r, g, b = alter(r, percent), alter(g, percent), alter(b, percent)
  r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
  return fmt('#%02x%02x%02x', r, g, b)
end

---@param group_name string A highlight group name
local function get_highlight(group_name)
  local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, true)
  if not ok then return {} end
  hl.foreground = hl.foreground and '#' .. bit.tohex(hl.foreground, 6)
  hl.background = hl.background and '#' .. bit.tohex(hl.background, 6)
  hl[true] = nil -- BUG: API returns a true key which errors during the merge
  return hl
end

--- Sets a neovim highlight with some syntactic sugar. It takes a highlight table and converts
--- any highlights specified as `GroupName = { from = 'group'}` into the underlying colour
--- by querying the highlight property of the from group so it can be used when specifying highlights
--- as a shorthand to derive the right color.
--- For example:
--- ```lua
---   M.set({ MatchParen = {foreground = {from = 'ErrorMsg'}}})
--- ```
--- This will take the foreground colour from ErrorMsg and set it to the foreground of MatchParen.
---@param name string
---@param opts HighlightKeys
---@overload fun(namespace: integer, name: string, opts: HighlightKeys)
function M.set(namespace, name, opts)
  if type(namespace) == 'string' and type(name) == 'table' then
    opts, name, namespace = name, namespace, 0
  end

  vim.validate({
    opts = { opts, 'table' },
    name = { name, 'string' },
    namespace = { namespace, 'number' },
  })

  local hl = get_highlight(opts.inherit or name)
  opts.inherit = nil

  for attr, value in pairs(opts) do
    if type(value) == 'table' and value.from then
      opts[attr] = M.get(value.from, vim.F.if_nil(value.attr, attr))
      if value.alter then opts[attr] = M.alter_color(opts[attr], value.alter) end
    end
  end

  rvim.wrap_err_msg(
    api.nvim_set_hl,
    fmt('Failed to set %s because', name),
    namespace,
    name,
    vim.tbl_extend('force', hl, opts)
  )
end

---Get the value a highlight group whilst handling errors, fallbacks nvim well as returning a gui value
---in the right format
---@param group string
---@param attribute string?
---@param fallback string?
---@return string | table
function M.get(group, attribute, fallback)
  assert(group, 'cannot get a highlight without specifying a group name')
  local data = get_highlight(group)
  if not attribute then return data end
  local attr = ({ fg = 'foreground', bg = 'background' })[attribute] or attribute
  local color = data[attr] or fallback
  if color then return color end
  local msg = fmt("%s's %s does not exist", group, attr)
  vim.schedule(function() vim.notify(msg, 'error') end)
  return 'NONE'
end

function M.clear_hl(name)
  assert(name, 'name is required to clear a highlight')
  api.nvim_set_hl(0, name, {})
end

---Apply a list of highlights
---@param hls table<string, HighlightKeys>
---@param namespace integer?
function M.all(hls, namespace)
  rvim.foreach(function(hl) M.set(namespace or 0, next(hl)) end, hls)
end

---------------------------------------------------------------------------------
-- Plugin highlights
---------------------------------------------------------------------------------
---Apply highlights for a plugin and refresh on colorscheme change
---@param name string plugin name
---@param opts table<string, table> map of highlights
function M.plugin(name, opts)
  -- Options can be specified by theme name so check if they have been or there is a general
  -- definition otherwise use the opts as is
  local theme = opts.theme
  if theme then
    local res, seen = {}, {}
    for _, hl in ipairs(vim.list_extend(theme[vim.g.colors_name] or {}, theme['*'] or {})) do
      local n = next(hl)
      if not seen[n] then res[#res + 1] = hl end
      seen[n] = true
    end
    opts = res
    if not next(opts) then return end
  end
  -- capitalise the name for autocommand convention sake
  name = name:gsub('^%l', string.upper)
  M.all(opts)
  rvim.augroup(fmt('%sHighlightOverrides', name), {
    {
      event = { 'ColorScheme' },
      command = function()
        -- Defer resetting these highlights to ensure they apply after other overrides
        vim.defer_fn(function() M.all(opts) end, 1)
      end,
    },
  })
end

return M
