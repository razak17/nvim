local api = vim.api
local ts = require'nvim-treesitter.ts_utils'
local tslocals = require'nvim-treesitter.locals'
local M = {}

local virt_enable = false
local ns_id = api.nvim_create_namespace('TSVirtualText')

local hl_virt_enable = false
local hl_ns_id = api.nvim_create_namespace('TSVirtualTextHlGroups')

-- matchit based on treesitter (experiment)
function _G.tsMatchit()
  local node = tslocals.containing_scope(ts.get_node_at_cursor(0), 0, true)
  local _, lnum, col = unpack(vim.fn.getcurpos())
  lnum = lnum - 1
  col = col - 1
  local srow, scol, erow, ecol = node:range()

  if lnum - srow < erow - lnum then
    api.nvim_win_set_cursor(0, {erow+1, ecol})
  else
    api.nvim_win_set_cursor(0, {srow+1, scol})
  end
end

function M.toggle_ts_virt_text()
  if virt_enable then
    virt_enable = false
    api.nvim_buf_clear_namespace(0, ns_id, 0,-1)
  else
    virt_enable = true
    M.ts_virt_text()
  end
end

function M.ts_virt_text()
  if not virt_enable then return end

  local node_info = require'nvim-treesitter'.statusline()
  if not node_info or node_info == "" then return end

  local cursor = api.nvim_win_get_cursor(0)
  api.nvim_buf_clear_namespace(0, ns_id, 0,-1)
  api.nvim_buf_set_virtual_text(0, ns_id, cursor[1]-1, {{ node_info, "TsVirtText" }}, {})
end

function M.toggle_ts_hl_groups()
  if hl_virt_enable then
    hl_virt_enable = false
    api.nvim_buf_clear_namespace(0, hl_ns_id, 0,-1)
  else
    hl_virt_enable = true
    M.ts_hl_groups()
  end
end

function M.ts_hl_groups()
  if not hl_virt_enable then return end

  local ns = api.nvim_get_namespaces()['treesitter/highlighter']
  local _, lnum, lcol = unpack(vim.fn.getcurpos())
  local extmarks = api.nvim_buf_get_extmarks(0, ns, {lnum-1, lcol-1}, {lnum-1, -1}, { details = true })
  local groups = {}

  for i, ext in ipairs(extmarks) do
    local infos = ext[4]
    if infos then
      local str = infos.hl_group
      if i ~= #extmarks then
        str = str..' > '
      end
      table.insert(groups, {str, infos.hl_group})
    end
  end

  api.nvim_buf_clear_namespace(0, hl_ns_id, 0,-1)
  api.nvim_buf_set_virtual_text(0, hl_ns_id, lnum-1, groups, {})
end

function M.matchit()
  api.nvim_buf_set_keymap(0, 'n', '%', ':lua tsMatchit()<CR>', {silent=true})
end

return M
