local M = {}

local Log = require "user.core.log"
local lsp_utils = require "user.lsp.utils"

function M.init_defaults(languages)
  languages = languages or lsp_utils.get_all_supported_filetypes()
  for _, entry in ipairs(languages) do
    if not rvim.lang[entry] then
      rvim.lang[entry] = {
        formatters = {},
        linters = {},
        lsp = {},
      }
    end
  end
end

---Resolve the configuration for a server based on both common and user configuration
---@param name string
---@param user_config table [optional]
---@return table
 function M.resolve_config(name, user_config)
  local config = {
    on_attach = require("user.lsp").global_on_attach,
    on_init = require("user.lsp").global_on_init,
    on_exit = require("user.lsp").global_on_exit,
    capabilities = require("user.lsp").global_capabilities(),
  }

  local has_custom_provider, custom_config = pcall(require, "user/lsp/providers/" .. name)
  if has_custom_provider then
    Log:debug("Using custom configuration for requested server: " .. name)
    config = vim.tbl_deep_extend("force", config, custom_config)
  end

  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end

  return config
end

-- manually start the server and don't wait for the usual filetype trigger from lspconfig
function M.buf_try_add(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  require("lspconfig")[server_name].manager.try_add_wrapper(bufnr)
end

-- check if the manager autocomd has already been configured since some servers can take a while to initialize
-- this helps guarding against a data-race condition where a server can get configured twice
-- which seems to occur only when attaching to single-files
function M.client_is_configured(server_name, ft)
  ft = ft or vim.bo.filetype
  local active_autocmds = vim.split(vim.fn.execute("autocmd FileType " .. ft), "\n")
  for _, result in ipairs(active_autocmds) do
    if result:match(server_name) then
      return true
    end
  end
  return false
end

---Setup a language server by providing a name
---@param server_name string name of the language server
---@param user_config table [optional] when available it will take predence over any default configurations
function M.setup(server_name, user_config)
  vim.validate { name = { server_name, "string" } }

  local already_configured = lsp_utils.is_client_active(server_name)
    or M.client_is_configured(server_name)

  if server_name ~= "html" and already_configured then
    Log:debug(
      string.format("[%q] is already configured. Ignoring repeated setup call.", server_name)
    )
    return
  end

  local config = M.resolve_config(server_name, user_config)

  local servers = require "nvim-lsp-installer.servers"
  local server_available, requested_server = servers.get_server(server_name)

  local is_overridden = vim.tbl_contains(rvim.lsp.override, server_name)

  if not server_available or is_overridden then
    pcall(function()
      require("lspconfig")[server_name].setup(config)
      M.buf_try_add(server_name)
    end)
    return
  end

  local install_notification = false

  if not requested_server:is_installed() then
    if rvim.lsp.automatic_servers_installation then
      Log:debug "Automatic server installation detected"
      requested_server:install()
      install_notification = true
    else
      Log:debug(requested_server.name .. " is not managed by the automatic installer")
    end
  end

  requested_server:on_ready(function()
    if install_notification then
      vim.notify(
        string.format("Installation complete for [%s] server", requested_server.name),
        vim.log.levels.INFO
      )
    end
    install_notification = false
    requested_server:setup(config)
  end)
end

M.overrides_setup = function (server_name)
  require("user.lsp.overrides").setup(server_name)
end

return M
