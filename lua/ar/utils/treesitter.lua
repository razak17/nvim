local M = {}

M._installed = nil ---@type table<string,string>?
M._queries = {} ---@type table<string,boolean>

---@param update boolean?
function M.get_installed(update)
  if update then
    M._installed, M._queries = {}, {}
    for _, path in ipairs(vim.api.nvim_get_runtime_file('parser/*', true)) do
      local lang = vim.fn.fnamemodify(path, ':t:r')
      M._installed[lang] = lang
    end
  end
  return M._installed or {}
end

---@param lang string
---@param query string
function M.have_query(lang, query)
  local key = lang .. ':' .. query
  if M._queries[key] == nil then
    M._queries[key] = vim.treesitter.query.get(lang, query) ~= nil
  end
  return M._queries[key]
end

---@param what string|number|nil
---@param query? string
---@overload fun(buf?:number):boolean
---@overload fun(ft:string):boolean
---@return boolean
function M.have(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == 'number' and vim.bo[what].filetype or what --[[@as string]]
  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or M.get_installed()[lang] == nil then return false end
  if query and not M.have_query(lang, query) then return false end
  return true
end

function M.foldexpr()
  return M.have(nil, 'folds') and vim.treesitter.foldexpr() or '0'
end

function M.indentexpr()
  local indentexpr
  if ar.has('tree-sitter-manager.nvim') then
    indentexpr = require('ar.ts_indent').indentexpr
  elseif ar.has('nvim-treesitter') then
    indentexpr = require('nvim-treesitter').indentexpr
  end
  if not indentexpr then return -1 end
  return M.have(nil, 'indents') and indentexpr() or -1
end

---@param cb fun()
function M.ensure_treesitter_cli(cb)
  if vim.fn.executable('tree-sitter') == 1 then return cb() end

  return vim.notify(
    '`tree-sitter` CLI executable not found. Run `:checkhealth nvim-treesitter` for more information.',
    vim.log.levels.ERROR
  )
end

return M
