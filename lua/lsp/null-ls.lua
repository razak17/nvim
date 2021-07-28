local M = {}

local lsp_utils = require "lsp.utils"
local null_ls = require "null-ls"
local sources = {}

local is_table = lsp_utils.is_table
local is_string = lsp_utils.is_string
local has_value = lsp_utils.has_value

local local_executables = { "prettier", "prettierd", "prettier_d_slim", "eslint_d", "eslint" }

local find_local_exe = function(exe)
  -- vim.cmd "let root_dir = FindRootDirectory()"
  -- local root_dir = vim.api.nvim_get_var "root_dir"
  -- local local_exe = root_dir .. "/node_modules/.bin/" .. exe
  local local_exe = exe
  return local_exe
end

local function setup_ls(exe, type)
  if has_value(local_executables, exe) then
    local smart_executable = null_ls.builtins[type][exe]
    local local_executable = find_local_exe(exe)
    if vim.fn.executable(local_executable) == 1 then
      smart_executable._opts.command = local_executable
      table.insert(sources, smart_executable)
    else
      if vim.fn.executable(exe) == 1 then
        table.insert(sources, smart_executable)
      end
    end
  else
    if vim.fn.executable(exe) == 1 then
      table.insert(sources, null_ls.builtins[type][exe])
    end
  end
  null_ls.register { sources = sources }
end

-- TODO: for linters and formatters with spaces and '-' replace with '_'
local function setup(filetype, type)
  local executables = nil
  if type == "diagnostics" then
    executables = rvim.lang[filetype].linters
  end
  if type == "formatting" then
    executables = rvim.lang[filetype].formatter.exe
  end

  if is_table(executables) then
    for _, exe in pairs(executables) do
      if exe ~= "" then
        setup_ls(exe, type)
      end
    end
  end
  if is_string(executables) and executables ~= "" then
    setup_ls(executables, type)
  end
end

-- TODO: return the formatter if one was registered, then turn off the builtin formatter
function M.setup(filetype)
  setup(filetype, "formatting")
  setup(filetype, "diagnostics")
  rvim.sources = sources
  return sources
end

return M
