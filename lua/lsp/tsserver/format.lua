local M = {}

-- vim.cmd "let proj = FindRootDirectory()"
-- local root_dir = vim.api.nvim_get_var "proj"

-- -- use the global prettier if you didn't find the local one
-- local prettier_instance = root_dir .. "/node_modules/.bin/prettier"
-- if vim.fn.executable(prettier_instance) ~= 1 then
--   prettier_instance = "prettier"
-- end
local prettier_instance = "prettier"

M.init = function()
  local filetype = {}
  filetype["javascript"] = {
    function()
      local args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))}
      local extend_args = {"--single-quote", "--trailing-comma all", "--jsx-single-quote"}
      for i = 1, #extend_args do
        table.insert(args, extend_args[i])
      end
      return {exe = prettier_instance, args = args, stdin = true}
    end,
  }
  filetype["javascriptreact"] = filetype["javascript"]
  filetype["typescript"] = filetype["javascript"]
  filetype["typescriptreact"] = filetype["javascript"]
  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

return M
