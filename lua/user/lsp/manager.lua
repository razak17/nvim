local M = {}

local Log = require('user.core.log')
local lsp_utils = require('user.utils.lsp')

---Resolve the configuration for a server by merging with the default config
---@param server_name string
---@return table
function M.resolve_config(server_name)
  local defaults = rvim.lsp.get_global_opts()
  local config = rvim.servers[server_name]
  if not config then return defaults end
  Log:debug('Using custom configuration for requested server: ' .. server_name)
  defaults = vim.tbl_deep_extend('force', defaults, config)
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

function M.already_configured(server_name)
  return lsp_utils.is_client_active(server_name) or M.client_is_configured(server_name)
end

---Setup a language server by providing a name
---@param server_name string name of the language server
function M.setup(server_name)
  vim.validate({ name = { server_name, 'string' } })
  if M.already_configured(server_name) then return end

  local config = M.resolve_config(server_name)
  M.launch_server(server_name, config)
end

---Setup a language server by providing a name
---@param server_name string name of the language server
function M.override_setup(server_name)
  vim.validate({ name = { server_name, 'string' } })
  if M.already_configured(server_name) then return end

  local config = M.resolve_config(server_name)
  M.launch_server(server_name, config)
end

return M
