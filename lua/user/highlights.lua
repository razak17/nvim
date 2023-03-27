local api, notify, fmt = vim.api, vim.notify, string.format

rvim.highlight = {}

---@alias ErrorMsg {msg: string}

---@alias HLAttrs {from: string, attr: "fg" | "bg", alter: integer}

---@class HLData
---@field fg string
---@field bg string
---@field bold boolean
---@field italic boolean
---@field undercurl boolean
---@field underline boolean
---@field underdotted boolean
---@field underdashed boolean
---@field underdouble boolean
---@field strikethrough boolean
---@field reverse boolean
---@field nocombine boolean
---@field link string
---@field default boolean

---@class HLArgs
---@field blend integer
---@field fg string | HLAttrs
---@field bg string | HLAttrs
---@field sp string | HLAttrs
---@field bold boolean
---@field italic boolean
---@field undercurl boolean
---@field underline boolean
---@field underdotted boolean
---@field underdashed boolean
---@field underdouble boolean
---@field strikethrough boolean
---@field reverse boolean
---@field nocombine boolean
---@field link string
---@field default boolean
---@field clear boolean
---@field inherit string

local attrs = {
  fg = true,
  bg = true,
  sp = true,
  blend = true,
  bold = true,
  italic = true,
  standout = true,
  underline = true,
  undercurl = true,
  underdouble = true,
  underdotted = true,
  underdashed = true,
  strikethrough = true,
  reverse = true,
  nocombine = true,
  link = true,
  default = true,
}

---Convert a hex color to RGB
---@param color string
---@return number, number, number
local function hex_to_rgb(color)
  local hex = color:gsub('#', '')
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5), 16)
end

local function alter(attribute, percent) return math.floor(attribute * (100 + percent) / 100) end

---@param color string A hex color
---@param percent integer a negative number darkens and a positive one brightens
function rvim.highlight.alter_color(color, percent)
  assert(color, 'cannot alter a color without specifying a color')
  local r, g, b = hex_to_rgb(color)
  if not r or not g or not b then return 'NONE' end
  r, g, b = alter(r, percent), alter(g, percent), alter(b, percent)
  r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
  return fmt('#%02x%02x%02x', r, g, b)
end

---@param opts {name: string?, link: boolean?}?
---@param ns integer?
---@return HLData
local function get_highlight(opts, ns)
  ns, opts = ns or 0, opts or {}
  opts.link = opts.link or false
  local hl = api.nvim_get_hl(ns, opts)
  hl.fg = hl.fg and '#' .. bit.tohex(hl.fg, 6)
  hl.bg = hl.bg and '#' .. bit.tohex(hl.bg, 6)
  return hl
end

---Get the value a highlight group whilst handling errors, fallbacks rvim well rvim returning a gui value
---If no attribute is specified return the entire highlight table
---in the right format
---@param group string
---@param attribute string?
---@param fallback string?
---@return string, ErrorMsg?
---@overload fun(group: string): HLData, ErrorMsg?
function rvim.highlight.get(group, attribute, fallback)
  assert(group, 'cannot get a highlight without specifying a group name')
  local data = get_highlight({ name = group })
  if not attribute then return data end
  assert(attrs[attribute], ('the attribute passed in is invalid: %s'):format(attribute))
  local color = data[attribute] or fallback
  if not color then
    return 'NONE',
      {
        msg = ('failed to get highlight %s for attribute %s \n%s'):format(
          group,
          attribute,
          debug.traceback()
        ),
      }
  end
  return color
end

---@param hl string | HLAttrs
---@param attr string
---@return HLData
---@return ErrorMsg?
local function resolve_from_attribute(hl, attr)
  if type(hl) ~= 'table' or not hl.from then return hl end
  local colour, err = rvim.highlight.get(hl.from, hl.attr or attr)
  if hl.alter then colour = rvim.highlight.alter_color(colour, hl.alter) end
  return colour, err
end

---@param name string
---@param opts HLArgs
---@overload fun(ns: integer, name: string, opts: HLArgs): ErrorMsg[]?
---@return ErrorMsg[]?
function rvim.highlight.set(ns, name, opts)
  if type(ns) == 'string' and type(name) == 'table' then
    opts, name, ns = name, ns, 0
  end

  vim.validate({ opts = { opts, 'table' }, name = { name, 'string' }, ns = { ns, 'number' } })

  local clear = opts.clear
  if clear then opts.clear = nil end

  local hl, errs = get_highlight({ name = opts.inherit or name }), {}
  for attribute, hl_data in pairs(opts) do
    local new_data, err = resolve_from_attribute(hl_data, attribute)
    if err then table.insert(errs, err) end
    if attrs[attribute] then hl[attribute] = new_data end
  end

  local ok, err = pcall(api.nvim_set_hl, ns, name, hl)
  if not ok then
    table.insert(errs, {
      msg = ('failed to set highlight %s with value %s, %s'):format(name, vim.inspect(hl), err),
    })
  end
  if #errs > 0 then return errs end
end

---Apply a list of highlights
---@param hls {[string]: HLArgs}[]
---@param namespace integer?
function rvim.highlight.all(hls, namespace)
  local errors = rvim.fold(function(errors, hl)
    local errs = rvim.highlight.set(namespace or 0, next(hl))
    if errs then vim.list_extend(errors, errs) end
    return errors
  end, hls)
  if #errors > 0 then
    vim.defer_fn(function()
      notify(rvim.fold(function(acc, err) return acc .. '\n' .. err.msg end, errors, ''), 'error')
    end, 1000)
  end
end

---------------------------------------------------------------------------------
-- Plugin highlights
---------------------------------------------------------------------------------
--- Takes the overrides for each theme and merges the lists, avoiding duplicates and ensuring
--- priority is given to specific themes rather than the fallback
---@param theme {  [string]: HLArgs[] }
---@return HLArgs[]
local function add_theme_overrides(theme)
  local res, seen = {}, {}
  local list = vim.list_extend(theme[vim.g.colors_name] or {}, theme['*'] or {})
  for _, hl in ipairs(list) do
    local n = next(hl)
    if not seen[n] then res[#res + 1] = hl end
    seen[n] = true
  end
  return res
end

---Apply highlights for a plugin and refresh on colorscheme change
---@param name string plugin name
---@param opts HLArgs[] | { theme: table<string, HLArgs[]> }
function rvim.highlight.plugin(name, opts)
  -- Options can be specified by theme name so check if they have been or there is a general
  -- definition otherwise use the opts rvim is
  if opts.theme then
    opts = add_theme_overrides(opts.theme)
    if not next(opts) then return end
  end
  -- capitalise the name for autocommand convention sake
  name = name:gsub('^%l', string.upper)
  rvim.highlight.all(opts)
  rvim.augroup(fmt('%sHighlightOverrides', name), {
    event = { 'ColorScheme' },
    command = function()
      -- Defer resetting these highlights to ensure they apply after other overrides
      vim.defer_fn(function() rvim.highlight.all(opts) end, 1)
    end,
  })
end
