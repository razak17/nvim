local M = {}

local Log = require('user.core.log')
local lsp_utils = require('user.utils.lsp')

---Resolve the configuration for a server by merging with the default config
---@param server_name string
---@vararg any config table [optional]
---@return table
function M.resolve_config(server_name, ...)
  local defaults = require('user.lsp').get_global_opts()

  local has_custom_provider, custom_config = pcall(require, 'user/lsp/providers/' .. server_name)
  if has_custom_provider then
    Log:debug('Using custom configuration for requested server: ' .. server_name)
    defaults = vim.tbl_deep_extend('force', defaults, custom_config)
  end

  defaults = vim.tbl_deep_extend('force', defaults, ...)

  return defaults
end

-- manually start the server and don't wait for the usual filetype trigger from lspconfig
function M.buf_try_add(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  require('lspconfig')[server_name].manager.try_add_wrapper(bufnr)
end

-- check if the manager autocomd has already been configured since some servers can take a while to initialize
-- this helps guarding against a data-race condition where a server can get configured twice
-- which seems to occur only when attaching to single-files
function M.client_is_configured(server_name, ft)
  ft = ft or vim.bo.filetype
  local active_autocmds = vim.split(vim.fn.execute('autocmd FileType ' .. ft), '\n')
  for _, result in ipairs(active_autocmds) do
    -- NOTE: make exception for html. Already have an autocomd in treesitter
    if server_name ~= 'html' and result:match(server_name) then
      Log:debug(string.format('[%q] is already configured', server_name))
      return true
    end
  end
  return false
end

function M.launch_server(server_name, config)
  pcall(function()
    require('lspconfig')[server_name].setup(config)
    M.buf_try_add(server_name)
  end)
end

---Setup a language server by providing a name
---@param server_name string name of the language server
---@param user_config table? when available it will take predence over any default configurations
function M.setup(server_name, user_config)
  vim.validate({ name = { server_name, 'string' } })
  user_config = user_config or {}

  if lsp_utils.is_client_active(server_name) or M.client_is_configured(server_name) then return end

  local config = M.resolve_config(server_name, user_config)
  M.launch_server(server_name, config)
end

M.override_setup = function(server_name) require('user.lsp.overrides').setup(server_name) end

return M
