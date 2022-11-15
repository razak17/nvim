local M = {}

--- Find the first entry for which the predicate returns true.

-- @param t The table
-- @param predicate The function called for each entry of t
-- @return The entry for which the predicate returned True or nil
local function find_first(t, predicate)
  for _, entry in pairs(t) do
    if predicate(entry) then return entry end
  end
  return nil
end

local function is_client_active(name)
  local clients = vim.lsp.get_active_clients()
  return find_first(clients, function(client) return client.name == name end)
end

local function resolve_mason_config(server_name)
  local found, mason_config =
    rvim.safe_require('mason-lspconfig.server_configurations.' .. server_name, { silent = true })
  if not found then return {} end
  local server_mapping = require('mason-lspconfig.mappings.server')
  local path = require('mason-core.path')
  local install_dir = path.package_prefix(server_mapping.lspconfig_to_package[server_name])
  return mason_config(install_dir) or {}
end

---Resolve the configuration for a server by merging with the default config
---@param server_name string
---@vararg any config table [optional]
---@return table
local function resolve_config(server_name, ...)
  local get_config = require('user.core.servers')
  local config = get_config.setup(server_name)
  config = vim.tbl_deep_extend('force', config, ...)
  return config
end

-- manually start the server and don't wait for the usual filetype trigger from lspconfig
local function buf_try_add(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  require('lspconfig')[server_name].manager.try_add_wrapper(bufnr)
end

-- check if the manager autocomd has already been configured since some servers can take a while to initialize
-- this helps guarding against a data-race condition where a server can get configured twice
-- which seems to occur only when attaching to single-files
local function client_is_configured(server_name, ft)
  ft = ft or vim.bo.filetype
  local active_autocmds = vim.api.nvim_get_autocmds({ event = 'FileType', pattern = ft })
  for _, result in ipairs(active_autocmds) do
    if result.desc ~= nil and result.desc:match('server ' .. server_name .. ' ') then
      return true
    end
  end
  return false
end

local function launch_server(server_name, config)
  pcall(function()
    local cmd = config.cmd
      or (function()
        local default_config =
          require('lspconfig.server_configurations.' .. server_name).default_config
        return default_config.cmd
      end)()
    -- some servers have dynamic commands defined with on_new_config
    if type(cmd) == 'table' and type(cmd[1]) == 'string' and rvim.executable(cmd[1]) ~= 1 then
      vim.notify(
        string.format('[%q] is missing from PATH or not executable.', cmd[1]),
        vim.log.levels.ERROR,
        {
          title = server_name,
        }
      )
      return
    end
    -- NOTE: handle rust-tools like this for now
    if server_name == 'rust_analyzer' then require('user.lsp.rust-tools') end
    if server_name ~= 'rust_analyzer' then require('lspconfig')[server_name].setup(config) end
    buf_try_add(server_name)
  end)
end

local function already_configured(server_name)
  return is_client_active(server_name) or client_is_configured(server_name)
end

---Setup a language server by providing a name
---@param server_name string name of the language server
---@param user_config table? when available it will take predence over any default configurations
function M.setup(server_name, user_config)
  if not rvim.plugins.SANE or not rvim.plugin_loaded('mason.nvim') then return end
  vim.validate({ name = { server_name, 'string' } })
  user_config = user_config or {}
  if already_configured(server_name) then return end
  local config = resolve_config(server_name, resolve_mason_config(server_name), user_config)
  launch_server(server_name, config)
end

return M
