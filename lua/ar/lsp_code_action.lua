-- ref: https://www.reddit.com/r/neovim/comments/1j8ofgj/snippet_get_vscode_like_ctrl_quickfix_in_neovim/
--------------------------------------------------------------------------------
--  Code Actions
--------------------------------------------------------------------------------
local lsp = vim.lsp

local M = {}

---@param results (lsp.Command|lsp.CodeAction)[]
---@param ctx lsp.HandlerContext
function M.better_code_actions(results, ctx)
  if not results or #results == 0 then return end

  local function apply_specific_code_action(res)
    lsp.buf.code_action({
      filter = function(action) return action.title == res.title end,
      apply = true,
    })
  end

  local actions = {
    ['Goto Definition'] = { priority = 4, call = lsp.buf.definition },
    ['Goto Implementation'] = { priority = 3, call = lsp.buf.implementation },
    ['Show References'] = { priority = 2, call = lsp.buf.references },
    ['Rename'] = { priority = 1, call = lsp.buf.rename },
  }

  vim.iter(results):each(function(res)
    local priority = 5
    if res.isPreferred then priority = res.kind == 'quickfix' and 7 or 6 end
    actions[res.title] = {
      priority = priority,
      call = function() apply_specific_code_action(res) end,
      orig = res,
    }
  end)

  local overrides = {
    ['Add all missing imports'] = {
      call = "lua require'ar.select_menus.lsp'.add_missing_imports()",
    },
    ['Organize imports'] = {
      call = "lua require'ar.select_menus.lsp'.organize_imports()",
    },
    ['Remove unused imports'] = {
      call = "lua require'ar.select_menus.lsp'.remove_unused_imports()",
    },
    ['Remove unused'] = {
      call = "lua require'ar.select_menus.lsp'.remove_unused()",
    },
    ['Fix all problems'] = {
      call = "lua require'ar.select_menus.lsp'.fix_all()",
    },
  }

  local items = vim
    .iter(actions)
    :map(
      function(k, v)
        return {
          action = { title = k },
          priority = v.priority,
          call = overrides[k] and overrides[k].call or v.call,
          ctx = ctx,
          orig = v.orig,
        }
      end
    )
    :totable()

  -- sort by priority, then by title
  table.sort(items, function(a, b)
    if a.priority == b.priority then return a.action.title < b.action.title end
    return a.priority > b.priority
  end)

  local select_opts = { prompt = 'Code actions:', kind = 'codeaction' }

  vim.ui.select(items, select_opts, function(choice)
    if choice ~= nil then
      if type(choice.call) == 'string' then
        vim.cmd(choice.call)
      elseif type(choice.call) == 'function' then
        choice.call()
      end
    end
  end)
end

return M
