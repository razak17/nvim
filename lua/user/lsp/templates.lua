local M = {}

local utils = require('user.utils')
local ftplugin_dir = rvim.lsp.templates_dir
local fmt = string.format

local function write_manager(filename, server_name)
  local cmd = fmt([[require("user.lsp.manager").setup(%q)]], server_name)
  utils.write_file(filename, cmd .. '\n', 'a')
end

---Get supported filetypes per server
---@param server_name string can be any server supported by nvim-lsp-installer
---@return string[] supported filestypes as a list of strings
local function get_supported_filetypes(server_name)
  local status_ok, config =
    pcall(require, ('lspconfig.server_configurations.%s'):format(server_name))
  if not status_ok then return {} end
  return config.default_config.filetypes or {}
end

---Get supported servers per filetype
---@param filter { filetype: string | string[] }?: (optional) Used to filter the list of server names.
---@return string[] list of names of supported servers
local function get_supported_servers(filter)
  local _, supported_servers = pcall(
    function() return require('mason-lspconfig').get_available_servers(filter) end
  )
  return supported_servers or {}
end

function M.remove_template_files()
  -- remove any outdated files
  for _, file in ipairs(vim.fn.glob(ftplugin_dir .. '/*.lua', 1, 1)) do
    vim.fn.delete(file)
  end
end

local function getFileTypes(server_name)
  local configured_filetypes = rvim.lsp.configured_filetypes
  return vim.tbl_filter(
    function(ft) return vim.tbl_contains(configured_filetypes, ft) end,
    get_supported_filetypes(server_name) or {}
  )
end

---Generates an ftplugin file based on the server_name in the selected directory
---@param server_name string name of a valid language server, e.g. pyright, gopls, tsserver, etc.
---@param dir string the full path to the desired directory
local function generate_ftplugin(server_name, dir)
  local filetypes = getFileTypes(server_name)
  if not filetypes then return end
  for _, filetype in ipairs(filetypes) do
    local filename = join_paths(dir, filetype .. '.lua')
    write_manager(filename, server_name)
    if server_name == 'tsserver' then
      local cmd = 'vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end'
      utils.write_file(filename, cmd .. '\n', 'a')
    end
  end
end

---Generates ftplugin files based on a list of server_names
---The files are generated to a runtimepath: "$RVIM_RUNTIME_DIR/site/after/ftplugin/template.lua"
function M.generate_templates()
  -- servers_names = servers_names or get_supported_servers()
  --NOTE: use custom server list for now
  M.remove_template_files()
  if not utils.is_directory(rvim.lsp.templates_dir) then vim.fn.mkdir(ftplugin_dir, 'p') end
  local server_name = require('user.core.servers').servers
  for server, v in pairs(server_name) do
    if v ~= false then generate_ftplugin(server, ftplugin_dir) end
  end
end

return M
