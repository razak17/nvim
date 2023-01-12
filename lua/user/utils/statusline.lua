local api = vim.api
local fmt = string.format
local empty = rvim.empty
local strwidth = api.nvim_strwidth

local M = {}

local constants = {
  HL_END = '%*',
  ALIGN = '%=',
  END = '%<',
  CLICK_END = '%X',
}

local function sum_lengths(list)
  return rvim.fold(function(acc, item) return acc + (item.length or 0) end, list, 0)
end

local function is_lowest(item, lowest)
  -- if there hasn't been a lowest selected so far
  -- then the item is the lowest
  if not lowest or not lowest.length then return true end
  -- if the item doesn't have a priority or a length
  -- it is likely a special character so should never
  -- be the lowest
  if not item.priority or not item.length then return false end
  -- if the item has the same priority as the lowest then if the item
  -- has a greater length it should become the lowest
  if item.priority == lowest.priority then return item.length > lowest.length end

  return item.priority > lowest.priority
end

--- Take the lowest priority items out of the statusline if we don't have
--- space for them.
--- TODO: currently this doesn't account for if an item that has a lower priority
--- could be fit in instead
--- @param statusline table
--- @param space number
--- @param length number
local function prioritize(statusline, space, length)
  length = length or sum_lengths(statusline)
  if length <= space then return statusline end
  local lowest
  local index_to_remove
  for idx, c in ipairs(statusline) do
    if is_lowest(c, lowest) then
      lowest = c
      index_to_remove = idx
    end
  end
  table.remove(statusline, index_to_remove)
  return prioritize(statusline, space, length - lowest.length)
end

--- @param hl string|number
local function wrap(hl)
  assert(hl, 'A highlight name must be specified')
  return '%#' .. hl .. '#'
end

----------------------------------------------------------------------------------------------------
-- COMPONENTS
----------------------------------------------------------------------------------------------------

---@param func_name string
---@param id string
---@return string
local function get_click_start(func_name, id) return '%' .. id .. '@' .. func_name .. '@' end

--- Creates a spacer statusline component i.e. for padding
--- or to represent an empty component
--- @param size integer?
--- @param opts table<string, any>?
function M.spacer(size, opts)
  opts = opts or {}
  local filler = opts.filler or ' '
  local priority = opts.priority or 0
  if size and size >= 1 then
    local spacer = string.rep(filler, size)
    return { component = spacer, length = strwidth(spacer), priority = priority }
  end
  return { component = '', length = 0, priority = priority }
end

--- @param component string
--- @param hl string | number
--- @param opts table
function M.component(component, hl, opts)
  -- do not allow empty values to be shown note 0 is considered empty
  -- since if there is nothing of something I don't need to see it
  if not component or component == '' or component == 0 then return M.spacer() end
  assert(
    opts and opts.priority,
    fmt("each item's priority is required: %s is missing one", component)
  )
  opts.padding = opts.padding or { suffix = true, prefix = true }
  local padding = ' '
  local before, after = opts.before or '', opts.after or padding
  local prefix = opts.prefix and opts.prefix .. (opts.padding.prefix and padding or '') or ''
  local suffix = opts.suffix and (opts.padding.suffix and padding or '') .. opts.suffix or ''
  local prefix_color, suffix_color = opts.prefix_color or hl, opts.suffix_color or hl
  local prefix_hl = not empty(prefix_color) and wrap(prefix_color) or ''
  local suffix_hl = not empty(suffix_color) and wrap(suffix_color) or ''
  local prefix_item = not empty(prefix) and prefix_hl .. prefix or ''
  local suffix_item = not empty(suffix) and suffix_hl .. suffix or ''

  local click_start = opts.click and get_click_start(opts.click, opts.id) or ''
  local click_end = opts.click and constants.CLICK_END or ''

  --- handle numeric inputs etc.
  if type(component) ~= 'string' then component = tostring(component) end

  if opts.max_size and component and #component >= opts.max_size then
    component = component:sub(1, opts.max_size - 1) .. '…'
  end

  return {
    component = table.concat({
      click_start,
      before,
      prefix_item,
      constants.HL_END,
      hl and wrap(hl) or '',
      component,
      constants.HL_END,
      suffix_item,
      after,
      click_end,
    }),
    length = strwidth(component .. before .. after .. suffix .. prefix),
    priority = opts.priority,
  }
end

----------------------------------------------------------------------------------------------------
-- RENDER
----------------------------------------------------------------------------------------------------

--- @param statusline table
--- @param available_space number
function M.display(statusline, available_space)
  local str = ''
  local items = prioritize(statusline, available_space)
  for _, item in ipairs(items) do
    if type(item.component) == 'string' and #item.component > 0 then str = str .. item.component end
  end
  return str
end

---Aggregate pieces of the statusline
---@param tbl table
---@return function
function M.winline(tbl)
  return function(...)
    for i = 1, select('#', ...) do
      tbl[#tbl + 1] = select(i, ...)
    end
  end
end

--- @class RawComponentOpts
--- @field priority number
--- @field win_id number
--- @field type "statusline" | "tabline" | "winbar"

---Render a component that already has statusline format items and highlights in place
---@param item string
---@param opts RawComponentOpts
---@return table
function M.component_raw(item, opts)
  local priority = opts.priority or 0
  local win_id = opts.win_id or 0
  local container_type = opts.type or 'statusline'
  ---@type table
  local data = api.nvim_eval_statusline(item, {
    use_winbar = container_type == 'winbar',
    use_tabline = container_type == 'tabline',
    winid = win_id,
  })
  return { component = item, length = data.width, priority = priority }
end

----------------------------------------------------------------------------------------------------
-- Lualine Stuff
----------------------------------------------------------------------------------------------------
M.conditions = {
  buffer_not_empty = function() return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 end,
  hide_in_width = function() return vim.fn.winwidth(0) > 99 end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

function M.diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

function M.env_cleanup(venv)
  if string.find(venv, '/') then
    local final_venv = venv
    for w in venv:gmatch('([^/]+)') do
      final_venv = w
    end
    venv = final_venv
  end
  return venv
end

function M.python_env()
  if vim.bo.filetype == 'python' then
    local venv = vim.env.CONDA_DEFAULT_ENV
    if venv then return string.format('(%s)', M.env_cleanup(venv)) end
    venv = vim.env.VIRTUAL_ENV
    if venv then return string.format('(%s)', M.env_cleanup(venv)) end
    return ''
  end
  return ''
end

return M
