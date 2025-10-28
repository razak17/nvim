-- Ref: https://github.com/neo451/dot/blob/6b108a76e97b02df7012e5b518ad56513d23ab4c/nvim/.config/nvim/plugin/lsp_dial.lua#L1

local function num2bool(num)
  return num == 1 and true or num == 0 and false or nil
end

local lsp = vim.lsp
local ms = lsp.protocol.Methods
local util = lsp.util

---@return lsp.CompletionItem[]
local function get_lsp_items()
  local params = util.make_position_params(0, 'utf-8')
  local results = lsp.buf_request_sync(0, ms.textDocument_completion, params)
  local items = {}
  if results and not vim.tbl_isempty(results) then
    local result = results[2].result
    if result then
      items = vim
        .iter(result.items)
        :filter(
          function(item)
            return item.kind == lsp.protocol.CompletionItemKind.EnumMember
          end
        )
        :totable()
    end
  end
  return items
end

---@param text string
---@param inc? boolean
local function get_enum_index(text, inc)
  local items = get_lsp_items()

  if vim.tbl_isempty(items) then return end

  local index

  for i, value in ipairs(items) do
    if value.label == text then
      index = i
      break
    end
  end

  if not index then return end

  if inc then
    index = index + 1
    if index > #items then index = 1 end
  else
    index = index - 1
    if index < 1 then index = #items end
  end

  local next_item = items[index]

  return index, next_item
end

local augend = require('dial.augend')
local config = require('dial.config')

config.augends:register_group({
  enum = {
    augend.user.new({
      find = function(line, _)
        local wORD = vim.fn.expand('<cWORD>')
        local s, e = line:find(wORD)
        if s and e then return { from = s, to = e } end
      end,
      add = function(text, addend, cursor)
        local _, next_item = get_enum_index(text, num2bool(addend))
        cursor = #text
        if next_item then
          return { text = next_item.label, cursor = cursor - 1 }
        end
        return { text = text, cursor = cursor - 1 }
      end,
    }),
  },
})

vim.keymap.set(
  'n',
  '<A-a>',
  require('dial.map').inc_normal('enum'),
  { noremap = true, desc = 'dial: next enum' }
)

vim.keymap.set(
  'n',
  '<A-x>',
  require('dial.map').dec_normal('enum'),
  { noremap = true, desc = 'dial: prev enum' }
)
