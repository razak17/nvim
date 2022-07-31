local api = vim.api
local fmt = string.format
local levels = vim.log.levels

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
local function get(group_name)
  local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, true)
  if ok then
    hl.foreground = hl.foreground and '#' .. bit.tohex(hl.foreground, 6)
    hl.background = hl.background and '#' .. bit.tohex(hl.background, 6)
    --- BUG: API returns a true key which errors during the merge
    hl[true] = nil
    return hl
  end
  return {}
end

---@param group_name string A highlight group name
local function get_hl(group_name)
  local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, true)
  if ok then
    hl.foreground = hl.foreground and '#' .. bit.tohex(hl.foreground, 6)
    hl.background = hl.background and '#' .. bit.tohex(hl.background, 6)
    hl[true] = nil -- BUG: API returns a true key which errors during the merge
    return hl
  end
  return {}
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
function M.set(name, opts)
  assert(name and opts, "Both 'name' and 'opts' must be specified")

  local hl = get_hl(opts.inherit or name)
  opts.inherit = nil

  for attr, value in pairs(opts) do
    if type(value) == 'table' and value.from then
      opts[attr] = M.get(value.from, vim.F.if_nil(value.attr, attr))
      if value.alter then opts[attr] = M.alter_color(opts[attr], value.alter) end
    end
  end

  local ok, msg = pcall(api.nvim_set_hl, 0, name, vim.tbl_deep_extend('force', hl, opts))
  if not ok then vim.notify(fmt('Failed to set %s because - %s', name, msg)) end
end

---Get the value a highlight group whilst handling errors, fallbacks nvim well as returning a gui value
---in the right format
---@param group string
---@param attribute string?
---@param fallback string?
---@return string | table
function M.get(group, attribute, fallback)
  if not group then
    vim.notify('Cannot get a highlight without specifying a group', levels.ERROR)
    return 'NONE'
  end
  local hl = get(group)
  if not attribute then return hl end
  attribute = ({ fg = 'foreground', bg = 'background' })[attribute] or attribute
  local color = hl[attribute] or fallback
  if not color then
    vim.schedule(
      function() vim.notify(fmt('%s %s does not exist', group, attribute), levels.INFO) end
    )
    return 'NONE'
  end
  -- convert the decimal RGBA value from the hl by name to a 6 character hex + padding if needed
  return color
end

function M.clear_hl(name)
  assert(name, 'name is required to clear a highlight')
  api.nvim_set_hl(0, name, {})
end

---Apply a list of highlights
---@param hls table<string, table<string, boolean|string|HighlightAttributes>>
function M.all(hls)
  for name, hl in pairs(hls) do
    M.set(name, hl)
  end
end

---------------------------------------------------------------------------------
-- Plugin highlights
---------------------------------------------------------------------------------
---Apply highlights for a plugin and refresh on colorscheme change
---@param name string plugin name
---@param hls table<string, table> map of highlights
function M.plugin(name, hls)
  name = name:gsub('^%l', string.upper) -- capitalise the name for autocommand convention sake
  M.all(hls)
  rvim.augroup(fmt('%sHighlightOverrides', name), {
    {
      event = { 'ColorScheme' },
      command = function()
        -- Defer resetting these highlights to ensure they apply after other overrides
        vim.defer_fn(function() M.all(hls) end, 1)
      end,
    },
  })
end

return M
