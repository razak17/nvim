local api, L = vim.api, vim.log.levels
local strwidth, fmt, falsy = api.nvim_strwidth, string.format, rvim.falsy

---@alias StringComponent {component: string, length: integer, priority: integer}

local M = {}

local constants = { HL_END = '%*', ALIGN = '%=', END = '%<', CLICK_END = '%X' }
local padding = ' '

M.constants = constants

--- @param hl string
local function wrap(hl)
  if not hl then return '' end
  return '%#' .. hl .. '#'
end

----------------------------------------------------------------------------------------------------
-- COMPONENTS
----------------------------------------------------------------------------------------------------

local function separator() return { component = constants.ALIGN, length = 0, priority = 0 } end

---@param func_name string
---@param id string
---@return string
local function get_click_start(func_name, id)
  if not id then
    vim.schedule(
      function()
        vim.notify_once(
          fmt('An ID is needed to enable click handler %s to work', func_name),
          L.ERROR,
          { title = 'Statusline' }
        )
      end
    )
    return ''
  end
  return '%' .. id .. '@' .. func_name .. '@'
end

--- Creates a spacer statusline component i.e. for padding
--- or to represent an empty component
--- @param size integer?
--- @param opts table<string, any>?
--- @return ComponentOpts?
function M.spacer(size, opts)
  opts = opts or {}
  local filler = opts.filler or ' '
  local priority = opts.priority or 0
  if not size or size == 0 then return end
  local spacer = string.rep(filler, size)
  return { { { spacer } }, priority = priority, before = '', after = '' }
end

--- truncate with an ellipsis or if surrounded by quotes, replace contents of quotes with ellipsis
--- @param str string
--- @param max_size integer
--- @return function(string): string
local function truncate_str(str, max_size)
  if not max_size or strwidth(str) < max_size then return str end
  local match, count = str:gsub('([\'"]).*%1', '%1…%1')
  return count > 0 and match or str:sub(1, max_size - 1) .. '…'
end

---@alias Subsection {[1]: string | number, [2]: string, max_size: integer?}[]

---@param subsection Subsection
---@return string, string
local function get_subsection(subsection)
  if not subsection or not vim.tbl_islist(subsection) then return '', '' end
  local section, items = {}, {}
  for _, item in ipairs(subsection) do
    local text, hl = unpack(item)
    if type(text) == 'string' then item = tostring(item) end --- handle numeric inputs etc.
    if item.max_size then text = truncate_str(text, item.max_size) end
    table.insert(items, text)
    table.insert(section, wrap(hl) .. text)
  end
  return table.concat(section), table.concat(items)
end

--- @class ComponentOpts
--- @field [1] Subsection
--- @field priority number
--- @field click string
--- @field before string
--- @field after string
--- @field id number
--- @field max_size integer
--- @field cond boolean | number | table | string,
--- @param opts ComponentOpts
--- @return StringComponent?
local function component(opts)
  assert(opts, 'component options are required')
  if opts.cond ~= nil and falsy(opts.cond) then return end

  local item = opts[1]
  if not vim.tbl_islist(item) then
    error(fmt('component options are required but got %s instead', vim.inspect(item)))
  end
  local before, after = opts.before or '', opts.after or padding

  local item_str = get_subsection(item)
  if strwidth(item_str) == 0 then return end

  local click_start = opts.click and get_click_start(opts.click, tostring(opts.id)) or ''
  local click_end = opts.click and constants.CLICK_END or ''

  local component_str = table.concat({
    click_start,
    before,
    item_str,
    constants.HL_END,
    after,
    click_end,
  })

  return {
    component = component_str,
    length = api.nvim_eval_statusline(component_str, { maxwidth = 0 }).width,
    priority = opts.priority,
  }
end

----------------------------------------------------------------------------------------------------
-- RENDER
----------------------------------------------------------------------------------------------------
local function sum_lengths(list)
  return vim.iter(list):fold(0, function(acc, item) return acc + (item.length or 0) end)
end

local function is_lowest(item, lowest)
  -- if there hasn't been a lowest selected so far, then the item is the lowest
  if not lowest or not lowest.length then return true end
  -- if the item doesn't have a priority or a length, it is likely a special character so should never be the lowest
  if not item.priority or not item.length then return false end
  -- if the item has the same priority rvim the lowest, then if the item has a greater length it should become the lowest
  if item.priority == lowest.priority then return item.length > lowest.length end
  return item.priority > lowest.priority
end

--- Take the lowest priority items out of the statusline if we don't have
--- space for them.
--- TODO: currently this doesn't account for if an item that has a lower priority
--- could be fit in instead
--- @param statusline table
--- @param space number
--- @param length? number
local function prioritize(statusline, space, length)
  length = length or sum_lengths(statusline)
  if length <= space then return statusline end
  local lowest, index_to_remove
  for idx, c in ipairs(statusline) do
    if is_lowest(c, lowest) then
      lowest, index_to_remove = c, idx
    end
  end
  table.remove(statusline, index_to_remove)
  return prioritize(statusline, space, length - lowest.length)
end

--- @param sections ComponentOpts[][]
--- @param available_space number?
--- @return string
function M.display(sections, available_space)
  local components = vim.iter(ipairs(sections)):fold({}, function(acc, count, section)
    if #section == 0 then
      table.insert(acc, separator())
      return acc
    end
    vim.iter(ipairs(section)):each(function(index, args)
      if not args then return end
      local ok, str = rvim.pcall('Error creating component', component, args)
      if not ok then return end
      table.insert(acc, str)
      if #section == index and count ~= #sections then table.insert(acc, separator()) end
    end)
    return acc
  end)

  local items = available_space and prioritize(components, available_space) or components
  local str = vim.tbl_map(function(item) return item.component end, items)
  return table.concat(str)
end

--- A helper class that allow collecting `...StringComponent`
--- into sections that can then be added to each other
--- i.e.
--- ```lua
--- section1:new(1, 2, 3) + section2:new(4, 5, 6) + section3(7, 8, 9)
--- {1, 2, 3, 4, 5, 6, 7, 8, 9} -- <--
--- ```
---@class Section
---@field __add fun(l:Section, r:Section): StringComponent[]
---@field __index Section
---@field new fun(...:StringComponent[]): Section
local section = {}
function section:new(...)
  local o = { ... }
  self.__index = self
  self.__add = function(l, r)
    local rt = { unpack(l) }
    for _, v in ipairs(r) do
      rt[#rt + 1] = v
    end
    return rt
  end
  return setmetatable(o, self)
end
M.section = section

return M
