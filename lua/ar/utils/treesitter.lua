local M = {}

M._installed = nil ---@type table<string,string>?

---@param update boolean?
function M.get_installed(update)
  if update then
    M._installed = {}
    for _, lang in ipairs(require('nvim-treesitter').get_installed('parsers')) do
      M._installed[lang] = lang
    end
  end
  return M._installed or {}
end

---@param what string|number|nil
---@overload fun(buf?:number):boolean
---@overload fun(ft:string):boolean
---@return boolean
function M.have(what)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == 'number' and vim.bo[what].filetype or what --[[@as string]]
  local lang = vim.treesitter.language.get_lang(what)
  return lang ~= nil and M.get_installed()[lang] ~= nil
end

function M.foldexpr() return M.have() and vim.treesitter.foldexpr() or '0' end

function M.indentexpr()
  return M.have() and require('nvim-treesitter').indentexpr() or -1
end

---@param cb fun()
function M.ensure_treesitter_cli(cb)
  if vim.fn.executable('tree-sitter') == 1 then return cb() end

  return vim.notify({
    '**treesitter-nvim** `main` requires the `tree-sitter` CLI executable to be installed.',
    'Please install it manually from https://github.com/tree-sitter/tree-sitter/tree/master/crates/cli or',
    'use your system package manager.',
    'Run `:checkhealth nvim-treesitter` for more information.',
  }, vim.log.levels.ERROR)
end

return M
