local M = {}

local fn, fmt = vim.fn, string.format

local function client_active(name)
  local clients = vim.lsp.get_active_clients()
  return rvim.find_first(clients, function(client) return client.name == name end)
end

local function resolve_mason_config(server_name)
  local found, mason_config = rvim.pcall(require, fmt('mason-lspconfig.server_configurations.%s', server_name))
  if not found then return {} end
  local server_mapping = require('mason-lspconfig.mappings.server')
  local path = require('mason-core.path')
  local pkg_name = server_mapping.lspconfig_to_package[server_name]
  local install_dir = path.package_prefix(pkg_name)
  return mason_config(install_dir) or {}
end

---Resolve the configuration for a server by merging with the default config
---@param server_name string
---@return table
local function resolve_config(server_name)
  local mason_config = resolve_mason_config(server_name)
  local config = require('user.servers')(server_name) or {}
  config = vim.tbl_deep_extend('force', mason_config, config)
  return config
end

-- manually start the server and don't wait for the usual filetype trigger from lspconfig
local function buf_try_add(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  require('lspconfig')[server_name].manager.try_add_wrapper(bufnr)
end

local function launch_server(server, config)
  rvim.pcall(function()
    local cmd = config.cmd
      or (function()
        local lspconfig = require(fmt('lspconfig.server_configurations.%s', server)).default_config
        return lspconfig.cmd
      end)()
    -- some servers have dynamic commands defined with on_new_config
    if type(cmd) == 'table' and type(cmd[1]) == 'string' and not fn.executable(cmd[1]) then
      vim.notify(fmt('[%q] is not executable.', cmd[1]), vim.log.levels.ERROR, { title = server })
      return
    end
    local is_custom = server == 'rust_analyzer' or false
    if server == 'rust_analyzer' then require('user.lsp.rust-tools') end
    if server == 'vtsls' then require('lspconfig.configs').vtsls = require('vtsls').lspconfig end
    if not is_custom then require('lspconfig')[server].setup(config) end
    buf_try_add(server)
  end)
end

---Setup a language server by providing a name
---@param server_name string name of the language server
function M.setup(server_name)
  if not rvim.plugins.enable then return end
  vim.validate({ name = { server_name, 'string' } })
  if client_active(server_name) then return end
  local config = resolve_config(server_name)
  launch_server(server_name, config)
end

return M
