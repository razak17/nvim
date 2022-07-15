local M = {}

local Log = require('user.core.log')
local utils = require('user.utils')
local ftplugin_dir = rvim.lsp.templates_dir
local fmt = string.format
local find_string = rvim.find_string
local lsp_utils = require('user.utils.lsp')

local function write_manager(filename, server_name)
  local cmd = fmt([[require("user.lsp.manager").setup(%q)]], server_name)
  utils.write_file(filename, cmd .. '\n', 'a')
end

local function write_override(filename, server_name)
  local cmd = fmt([[require("user.lsp.manager").override_setup(%q)]], server_name)
  utils.write_file(filename, cmd .. '\n', 'a')
end

local function write_ft(filename, filetype)
  local cmd = fmt([[require("user.utils.ftplugin").setup(%q)]], filetype)
  utils.write_file(filename, cmd .. '\n', 'a')
end

function M.remove_template_files()
  -- remove any outdated files
  for _, file in ipairs(vim.fn.glob(ftplugin_dir .. '/*.lua', 1, 1)) do
    vim.fn.delete(file)
  end
end

---Generates an ftplugin file based on the server_name in the selected directory
---@param server_name string name of a valid language server, e.g. pyright, gopls, tsserver, etc.
---@param dir string the full path to the desired directory
function M.generate_ftplugin(server_name, dir)
  local skipped_filetypes = rvim.lsp.skipped_filetypes
  -- get the supported filetypes and remove any ignored ones
  local filetypes = vim.tbl_filter(
    function(ft) return not vim.tbl_contains(skipped_filetypes, ft) end,
    lsp_utils.get_supported_filetypes(server_name) or {}
  )

  if not filetypes then return end

  for _, filetype in ipairs(filetypes) do
    local filename = join_paths(dir, filetype .. '.lua')

    if find_string(rvim.lsp.override_servers, server_name) then
      write_override(filename, server_name)
    else
      write_manager(filename, server_name)
    end
  end
end

---Generates or writes to an ftplugin file based on filetype
---@param dir string the full path to the desired directory
function M.generate_ftplugin_util(dir)
  -- emmet
  for _, filetype in ipairs(rvim.lsp.emmet_ft) do
    local filename = join_paths(dir, filetype .. '.lua')
    write_manager(filename, 'emmet_ls')
  end
  -- ftplugin settings
  for _, filetype in ipairs(rvim.util.ftplugin_filetypes) do
    local filename = join_paths(dir, filetype .. '.lua')

    local react_fts = { 'typescript.tsx', 'javascript.jsx' }

    -- jsx/tsx in js/ts
    if find_string(react_fts, filetype) then
      write_ft(filename, 'javascriptreact')
    else
      write_ft(filename, filetype)
    end
  end
end

---Generates ftplugin files based on a list of server_names
---The files are generated to a runtimepath: "$LUNARVIM_RUNTIME_DIR/site/after/ftplugin/template.lua"
---@param servers_names table list of servers to be enabled. Will add all by default
function M.generate_templates(servers_names)
  servers_names = servers_names or {}

  Log:debug('Templates installation in progress')

  M.remove_template_files()

  if vim.tbl_isempty(servers_names) then
    local configured_servers = rvim.lsp.configured_servers

    for _, server in pairs(configured_servers) do
      table.insert(servers_names, server)
      table.sort(servers_names)
    end
  end

  -- create the directory if it didn't exist
  if not utils.is_directory(rvim.lsp.templates_dir) then vim.fn.mkdir(ftplugin_dir, 'p') end

  for _, server in ipairs(servers_names) do
    M.generate_ftplugin(server, ftplugin_dir)
  end

  -- ftplugin settings
  M.generate_ftplugin_util(ftplugin_dir)

  Log:debug('Templates installation is complete')
end

return M
