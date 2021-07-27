local M = {}

local formatter = 'prettier'

local get_formatter_instance = function()
  vim.cmd "let proj = FindRootDirectory()"
  local root_dir = vim.api.nvim_get_var "proj"

  -- prioritize local instance over global
  local local_instance = root_dir .. "/node_modules/.bin/" .. formatter
  if vim.fn.executable(local_instance) == 1 then
    return local_instance
  end
  return formatter
end

local format = function()
  local filetype = {}
  filetype["javascript"] = {
    function()
      local args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))}
      local extend_args = {}
      for i = 1, #extend_args do
        table.insert(args, extend_args[i])
      end
      return {exe = get_formatter_instance(), args = args, stdin = true}
    end,
  }
  filetype["javascriptreact"] = filetype["javascript"]
  filetype["typescript"] = filetype["javascript"]
  filetype["typescriptreact"] = filetype["javascript"]
  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.init = function()
  format()
end

return M
