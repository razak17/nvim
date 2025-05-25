-- ref: https://www.reddit.com/r/neovim/comments/1j8ofgj/snippet_get_vscode_like_ctrl_quickfix_in_neovim/
--------------------------------------------------------------------------------
--  Code Actions
--------------------------------------------------------------------------------
local lsp = vim.lsp
local ms = vim.lsp.protocol.Methods
local lsp_menus = require('ar.select_menus.lsp')
local util = require('vim.lsp.util')

local M = {}

local call_overrides = {
  ['Add all missing imports'] = lsp_menus.add_missing_imports,
  ['Organize imports'] = lsp_menus.organize_imports,
  ['Remove unused imports'] = lsp_menus.remove_unused_imports,
  ['Remove unused'] = lsp_menus.remove_unused,
  ['Fix all problems'] = lsp_menus.fix_all,
}

local ts_priority_overrides = {
  ['Organize imports'] = 7,
  ['Remove unused imports'] = 7,
  ['Remove unused'] = 7,
  ['Add all missing imports'] = 7,
  ['Update import from'] = 8,
  ['Add import from'] = 8,
  ['Remove unused declaration for'] = 8,
}

local priority_overrides = {
  ['typescript-tools'] = ts_priority_overrides,
  ts_ls = ts_priority_overrides,
  vtsls = ts_priority_overrides,
}

---@param title string
---@return string
local function format_title(title)
  -- Match actions such as 'Add import from "foo"' or 'Update import from "../foo"'
  local before, quoted = title:match('^(.+)%s+"([^"]+)"$')
  local is_import_export = before and quoted
  if is_import_export then title = title:match('^(.-)"'):gsub('%s+$', '') end
  -- Match actions such as 'Remove unused declaration: 'foo''
  local prefix, quoted_single = title:match("^(.-):%s*'([^']+)'$")
  local is_remove_declaration = prefix and quoted_single
  if is_remove_declaration then title = string.match(title, '^(.-):') end
  return title
end

---@param action lsp.Command|lsp.CodeAction
---@param client vim.lsp.Client
---@param ctx lsp.HandlerContext
local function apply_action(action, client, ctx)
  if action.edit then
    util.apply_workspace_edit(action.edit, client.offset_encoding)
  end
  local a_cmd = action.command
  if a_cmd then
    local command = type(a_cmd) == 'table' and a_cmd or action
    --- @cast command lsp.Command
    client:exec_cmd(command, ctx)
  end
end

local function apply_specific_code_action(choice)
  local client = assert(lsp.get_client_by_id(choice.ctx.client_id))
  local action = choice.action
  local bufnr = assert(choice.ctx.bufnr, 'Must have buffer number')

  -- Only code actions are resolved, so if we have a command, just apply it.
  if type(action.title) == 'string' and type(action.command) == 'string' then
    apply_action(action, client, choice.ctx)
    return
  end

  if
    not (action.edit and action.command)
    and client:supports_method(ms.codeAction_resolve)
  then
    client:request(ms.codeAction_resolve, action, function(err, resolved_action)
      if err then
        -- If resolve fails, try to apply the edit/command from the original code action.
        if action.edit or action.command then
          apply_action(action, client, choice.ctx)
        else
          vim.notify(err.code .. ': ' .. err.message, vim.log.levels.ERROR)
        end
      else
        apply_action(resolved_action, client, choice.ctx)
      end
    end, bufnr)
  else
    apply_action(action, client, choice.ctx)
  end

  -- lsp.buf.code_action({
  --   filter = function(action)
  --     return format_title(action.title) == format_title(choice.action.title)
  --   end,
  --   apply = true,
  -- })
end

local function get_base_actions(client)
  local default_actions = {
    ['Goto Definition'] = { priority = 4, call = lsp.buf.definition },
    ['Goto Implementation'] = { priority = 3, call = lsp.buf.implementation },
    ['Show References'] = { priority = 2, call = lsp.buf.references },
    ['Rename'] = { priority = 1, call = lsp.buf.rename },
  }

  local base_actions = {
    basedpyright = default_actions,
    ts_ls = default_actions,
    vtsls = default_actions,
    ['typescript-tools'] = default_actions,
  }
  return base_actions[client] or {}
end

---@param results vim.lsp.CodeActionResultEntry
local function on_code_action_results(results)
  ---@type {action: lsp.Command|lsp.CodeAction, ctx: lsp.HandlerContext}[]
  local actions = {}
  for _, result in pairs(results) do
    for _, action in pairs(result.result or {}) do
      table.insert(actions, { action = action, ctx = result.ctx })
    end
  end
  if #actions == 0 then return end

  local priority_actions = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client then
      priority_actions =
        vim.tbl_extend('force', priority_actions, get_base_actions(client.name))
    end
  end

  vim.iter(actions):each(function(a)
    local priority = 5
    if a.isPreferred then priority = a.kind == 'quickfix' and 7 or 6 end
    local title = a.action.title
    local client = lsp.get_client_by_id(a.ctx.client_id)
    if client then
      local overrides = priority_overrides[client.name]
      if overrides then
        priority = overrides[format_title(title)] or priority
      end
    end
    priority_actions[title] = {
      priority = priority,
      call = function() apply_specific_code_action(a) end,
      orig = a,
      ctx = a.ctx,
    }
  end)

  local file_path = vim.fn.expand('%:p')
  local items = vim
    .iter(priority_actions)
    :map(function(k, v)
      local item = {
        title = k,
        action = v.orig and v.orig.action or {
          title = k,
          data = v.orig and v.orig.data or 'file://' .. file_path,
          kind = v.orig and v.orig.kind or 'quickfix',
        },
        ctx = v.ctx or {},
        priority = v.priority,
        call = call_overrides[k] or v.call,
      }
      return item
    end)
    :totable()

  -- sort by priority, then by title
  table.sort(items, function(a, b)
    if a.priority == b.priority then return a.action.title < b.action.title end
    return a.priority > b.priority
  end)

  local select_opts = {
    prompt = 'Code actions:',
    kind = 'codeaction',
    format_item = function(item)
      if ar.falsy(item.ctx) then return item.title end
      clients = lsp.get_clients({ bufnr = item.ctx.bufnr })
      local title = item.action.title:gsub('\r\n', '\\r\\n'):gsub('\n', '\\n')

      if #clients == 1 then return title end

      local source = lsp.get_client_by_id(item.ctx.client_id).name
      return ('%s [%s]'):format(title, source)
    end,
  }

  vim.ui.select(items, select_opts, function(choice)
    if choice == nil then return end
    -- BUG: There is a bug in snacks.picket that shifts the cursor position one
    -- row to the left after vim.ui.select item is selected. This causes some
    -- actions (default ones. i.e. go to definition etc.) to  fail in some cases
    if type(choice.call) == 'string' then vim.cmd(choice.call) end
    if type(choice.call) == 'function' then choice.call() end
  end)
end

---@param bufnr number
---@param params lsp.CodeActionParams
function M.better_code_actions(bufnr, params)
  local clients =
    lsp.get_clients({ bufnr = bufnr, method = ms.textDocument_codeAction })
  local remaining = #clients
  if remaining == 0 then return end

  ---@type table<integer, vim.lsp.CodeActionResultEntry>
  local results = {}

  for _, client in ipairs(clients) do
    client:request(
      ms.textDocument_codeAction,
      params,
      function(err, result, ctx)
        results[ctx.client_id] = { error = err, result = result, ctx = ctx }
        remaining = remaining - 1
        if remaining == 0 then on_code_action_results(results) end
      end,
      bufnr
    )
  end
end

return M
