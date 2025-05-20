-- ref: https://www.reddit.com/r/neovim/comments/1j8ofgj/snippet_get_vscode_like_ctrl_quickfix_in_neovim/
--------------------------------------------------------------------------------
--  Code Actions
--------------------------------------------------------------------------------
local lsp = vim.lsp
local m = vim.lsp.protocol.Methods
local lsp_menus = require('ar.select_menus.lsp')

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
  ['Add all missing imports'] = 7,
  ['Update import from'] = 8,
  ['Add import from'] = 8,
}

local priority_overrides = {
  ['typescript-tools'] = ts_priority_overrides,
  ts_ls = ts_priority_overrides,
  vtsls = ts_priority_overrides,
}

local function apply_specific_code_action(res)
  lsp.buf.code_action({
    filter = function(action) return action.title == res.title end,
    apply = true,
  })
end

---@param client vim.lsp.Client
---@param bufnr number
---@param params lsp.CodeActionParams
function M.better_code_actions(client, bufnr, params)
  local file_path = vim.fn.expand('%:p')
  local actions = {
    ['Goto Definition'] = { priority = 4, call = lsp.buf.definition },
    ['Goto Implementation'] = { priority = 3, call = lsp.buf.implementation },
    ['Show References'] = { priority = 2, call = lsp.buf.references },
    ['Rename'] = { priority = 1, call = lsp.buf.rename },
  }

  lsp.buf_request(
    bufnr,
    m.textDocument_codeAction,
    params,
    function(_, results, ctx, _)
      if not results or #results == 0 then return end

      ---@param res lsp.CodeAction
      ---@return string
      local function get_title(res)
        local title = res.title
        -- Match actions such as 'Add import from "foo"' or 'Update import from "../foo"'
        local before, quoted = title:match('^(.+)%s+"([^"]+)"$')
        if before and quoted then
          title = title:match('^(.-)"'):gsub('%s+$', '')
        end
        return title
      end

      vim.iter(results):each(function(res)
        local priority = 5
        if res.isPreferred then priority = res.kind == 'quickfix' and 7 or 6 end
        local overrides = priority_overrides[client.name]
        if overrides then priority = overrides[get_title(res)] or priority end
        actions[res.title] = {
          priority = priority,
          call = function() apply_specific_code_action(res) end,
          orig = res,
        }
      end)

      local items = vim
        .iter(actions)
        :map(
          function(k, v)
            return {
              action = {
                title = k,
                data = v.orig and v.orig.data or 'file://' .. file_path,
                kind = v.orig and v.orig.kind or 'quickfix',
              },
              ctx = ctx,
              priority = v.priority,
              call = call_overrides[k] or v.call,
            }
          end
        )
        :totable()

      -- sort by priority, then by title
      table.sort(items, function(a, b)
        if a.priority == b.priority then
          return a.action.title < b.action.title
        end
        return a.priority > b.priority
      end)

      local select_opts = {
        prompt = 'Code actions:',
        kind = 'codeaction',
        format_item = function(item)
          local clients = lsp.get_clients({ bufnr = item.ctx.bufnr })
          local title =
            item.action.title:gsub('\r\n', '\\r\\n'):gsub('\n', '\\n')

          if #clients == 1 then return title end

          local source = lsp.get_client_by_id(item.ctx.client_id).name
          return ('%s [%s]'):format(title, source)
        end,
      }

      vim.ui.select(items, select_opts, function(choice)
        if choice == nil then return end
        if type(choice.call) == 'string' then
          vim.cmd(choice.call)
        elseif type(choice.call) == 'function' then
          choice.call()
        end
      end)
    end
  )
end

return M
