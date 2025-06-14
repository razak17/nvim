-- https://github.com/folke/snacks.nvim/blob/bc0630e43be5699bb94dadc302c0d21615421d93/lua/snacks/picker/select.lua?plain=1#L9

---@generic T
---@param items T[] Arbitrary items
---@param opts? {prompt?: string, format_item?: (fun(item: T): string), kind?: string}
---@param on_choice fun(item?: T, idx?: number)
local function snacks_ui_select(items, opts, on_choice)
  opts = opts or {}

  ---@type snacks.picker.finder.Item[]
  local finder_items = {}
  for idx, item in ipairs(items) do
    local text = (opts.format_item or tostring)(item)
    table.insert(finder_items, {
      formatted = text,
      text = idx .. ' ' .. text,
      item = item,
      idx = idx,
    })
  end

  local title = opts.prompt or 'Select'
  title = title:gsub('^%s*', ''):gsub('[%s:]*$', '')
  local completed = false

  ---@type snacks.picker.finder.Item[]
  return Snacks.picker.pick({
    source = 'select',
    items = finder_items,
    format = Snacks.picker.format.ui_select(opts.kind, #items),
    title = title,
    layout = {
      layout = {
        height = math.floor(math.min(vim.o.lines * 0.5 - 10, #items + 2) + 0.5),
      },
    },
    actions = {
      confirm = function(picker, item)
        if completed then return end
        completed = true
        picker:close()
        vim.schedule(
          function() on_choice(item and item.item, item and item.idx) end
        )
      end,
    },
    on_close = function()
      if completed then return end
      completed = true
      vim.schedule(on_choice)
    end,
  })
end

return {
  desc = 'snacks ui select',
  recommended = true,
  'folke/snacks.nvim',
  opts = function(_, opts)
    local snack_opts = vim.tbl_deep_extend('force', opts or {}, {
      picker = { ui_select = false },
    })
    if ar_config.picker.variant == 'snacks' then
      vim.ui.select = snacks_ui_select
    end
    return snack_opts
  end,
}
