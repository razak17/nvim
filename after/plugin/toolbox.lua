local enabled = false

if not ar or ar.none or not enabled then return end

---@class toolbox.Command
---@field name string
---@field execute fun()
---
---@class toolbox.finder.Item : snacks.picker.finder.Item
---@field idx number
---@field name string
---@field divider boolean
---@field execute fun()

---@type toolbox.Command[]
local picker_cmds = {
  {
    name = 'Jump history',
    execute = function() require('snacks').picker.jumps() end,
  },
}

---@type toolbox.Command[]
local toggle_cmds = {
  {
    name = 'Toggle distraction free mode',
    execute = function()
      require('ms.bufferline').toggle()
      require('ms.lualine').toggle()
    end,
  },
  {
    name = 'Toggle dim mode',
    execute = function()
      local snacks_dim = require('snacks').dim
      if snacks_dim.enabled then
        snacks_dim.disable()
      else
        snacks_dim.enable()
      end
    end,
  },
  {
    name = 'Toggle zen mode',
    execute = function() require('snacks').zen() end,
  },
  {
    name = 'Toggle indent guides',
    execute = function()
      local snacks_indent = require('snacks').indent
      if snacks_indent.enabled then
        snacks_indent.disable()
      else
        snacks_indent.enable()
      end
    end,
  },
}

---@type toolbox.Command[]
local notification_cmds = {
  {
    name = 'Show notifications',
    execute = function() require('snacks').notifier.show_history() end,
  },
  {
    name = 'Hide notifications',
    execute = function() require('snacks').notifier.hide() end,
  },
}

local divider = {
  name = '-',
  execute = function() end,
}

---@param tbl table
---@param insert_tbl table
-- ---@return table
local function tbl_insert(tbl, insert_tbl)
  for _, v in ipairs(insert_tbl) do
    table.insert(tbl, v)
  end
end

---@return toolbox.Command[]
local function all_commands()
  ---@type toolbox.Command[]
  local cmds = {}
  tbl_insert(cmds, picker_cmds)
  table.insert(cmds, divider)
  tbl_insert(cmds, toggle_cmds)
  table.insert(cmds, divider)
  tbl_insert(cmds, notification_cmds)
  return cmds
end

---@return toolbox.finder.Item[]
local function get_items()
  ---@type toolbox.finder.Item[]
  local items = {}
  local commands = all_commands()
  for i, v in ipairs(commands) do
    ---@type toolbox.finder.Item
    local item = {
      idx = i,
      text = v.name,
      name = v.name,
      execute = v.execute,
      divider = v.name == '-',
    }
    table.insert(items, item)
  end
  return items
end

local function show_toolbox()
  local last_idx = 0
  local items = get_items()

  Snacks.picker({
    title = '@ms Toolbox',
    source = 'ms_toolbox',
    items = items,
    format = function(item, picker)
      local width = picker.layout.opts.layout.width * vim.o.columns
      width = math.floor(width)
      width = (width / 10) * 10 - 4

      local text = items[item.idx].divider and string.rep(item.text, width)
        or item.text

      ---@type snacks.picker.Highlight[]
      return {
        { text, item.text_hl },
      }
    end,
    on_change = function(picker, item)
      if items[item.idx].divider then
        if last_idx < item.idx then
          picker:action('list_down')
        else
          picker:action('list_up')
        end
      end
      last_idx = item.idx
    end,
    layout = { preset = 'select' },
    confirm = function(picker, item)
      picker:close()
      items[item.idx].execute()
    end,
  })
end

map('n', '<leader>oO', show_toolbox, { desc = 'show toolbox' })
