local api, fn = vim.api, vim.fn

local M = {}

local function lsp_clients(bufnr)
  return require('ar.select.lsp').lsp_clients(bufnr)
end

local function lsp_check_capabilities(feature, bufnr)
  local clients = lsp_clients(bufnr)
  for _, client in pairs(clients) do
    if client.server_capabilities[feature] then return true end
  end
  return false
end

function M.display_lsp_references()
  local refs_opts = { layout = { preview = 'main', preset = 'ivy' } }
  if not lsp_check_capabilities('callHierarchyProvider', 0) then
    Snacks.picker.lsp_references(refs_opts)
    return
  end

  vim.lsp.buf_request(
    0,
    'textDocument/prepareCallHierarchy',
    vim.lsp.util.make_position_params(),
    function(_, result)
      if result == nil or #result < 1 then
        Snacks.picker.lsp_references(refs_opts)
        return
      end
      local call_hierarchy_item = result[1]
      vim.lsp.buf_request(
        0,
        'callHierarchy/incomingCalls',
        { item = call_hierarchy_item },
        function(_, res)
          if res and #res > 0 then
            Snacks.picker.lsp_incoming_calls(refs_opts)
            return
          end
          Snacks.picker.lsp_references(refs_opts)
        end
      )
    end
  )
end

--------------------------------------------------------------------------------
-- Call Hierarchy
--------------------------------------------------------------------------------
local function get_call_hierarchy_for_item(call_hierarchy_item)
  local call_tree = {}
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchy_incomingCalls
  local by_lsp = vim.lsp.buf_request_sync(
    0,
    'callHierarchy/incomingCalls',
    { item = call_hierarchy_item }
  )
  if #by_lsp >= 1 and by_lsp then
    local result = by_lsp[vim.tbl_keys(by_lsp)[1]].result
    if #result >= 1 then
      for _, item in ipairs(result) do
        -- "group by" URL, because two calling classes/functions could have the same name,
        -- but different URIs/being distinct. If we grouped by name, we'd merge them.
        call_tree[item.from.uri] = {
          item = item,
          nested_hierarchy = get_call_hierarchy_for_item(item.from),
        }
      end
    end
  end
  return call_tree
end

local function hierarchy_path(entry)
  local path = entry.item.item.from.uri:gsub('^file:..', '')
  local short = path:match('[^/]+/[^/]+$') or path
  local lnum = entry.item.item.fromRanges[1].start.line + 1
  return path, short, lnum
end

local function collect_hierarchy(item, parent, res)
  local path, short, lnum = hierarchy_path(item)
  local current = {
    name = item.item.from.name,
    text = string.format('%s:%d', short, lnum),
    file = path,
    pos = { lnum, 0 },
    parent = parent,
  }
  table.insert(res, current)
  for _, nested_h in pairs(item.nested_hierarchy) do
    collect_hierarchy(nested_h, current, res)
  end
end

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_prepareCallHierarchy
function M.display_call_hierarchy()
  local by_lsp = vim.lsp.buf_request_sync(
    0,
    'textDocument/prepareCallHierarchy',
    vim.lsp.util.make_position_params()
  )
  if by_lsp ~= nil and #by_lsp >= 1 then
    local result = by_lsp[vim.tbl_keys(by_lsp)[1]].result
    if #result >= 1 then
      local call_hierarchy_item = result[1]
      local call_tree = get_call_hierarchy_for_item(call_hierarchy_item)
      local data = {}
      for _, caller_info in pairs(call_tree) do
        collect_hierarchy(caller_info, nil, data)
      end

      Snacks.picker.pick({
        title = 'Incoming calls: ' .. call_hierarchy_item.name,
        items = data,
        preview = 'file',
        layout = { preview = 'main', preset = 'ivy' },
        format = function(entry, picker)
          local format = Snacks.picker.format
          local out = {}
          vim.list_extend(out, format.tree(entry, picker))
          out[#out + 1] = {
            entry.name,
            entry.parent and 'SnacksPickerLspSymbol' or 'SnacksPickerSpecial',
          }
          out[#out + 1] = { '  ' }
          out[#out + 1] = { entry.text, 'SnacksPickerComment' }
          return out
        end,
      })
    end
  end
end

local function filter_lsp_symbols(query)
  if #vim.lsp.get_clients() == 0 then
    -- no LSP clients. I'm probably in a floating window.
    -- close it so we focus on the parent window that has a LSP
    if api.nvim_win_get_config(0).zindex > 0 then
      api.nvim_win_close(0, false)
    end
  end
  Snacks.picker.lsp_workspace_symbols({ search = query })
end

function M.filter_lsp_workspace_symbols()
  vim.ui.input(
    { prompt = 'Enter LSP symbol filter please: ', kind = 'center_win' },
    function(word)
      if word ~= nil then filter_lsp_symbols(word) end
    end
  )
end

function M.ws_symbol_under_cursor()
  local word = fn.expand('<cword>')
  filter_lsp_symbols(word)
end

return M
