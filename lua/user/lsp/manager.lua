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

  -- sqls
  if server_name == 'sqls' then
    config = vim.tbl_extend('force', config, {
      on_attach = function(client, bufnr) require('sqls').on_attach(client, bufnr) end,
    })
    require('lspconfig').sqls.setup(config)
  end

  -- rust_analyzer
  -- FIX: waiting for cargo metadata or cargo check (figure out fix)
  if server_name == 'rust_analyzer' then
    local status_ok, rust_tools = rvim.safe_require('rust-tools')
    if not status_ok then
      Log:debug('Failed to load rust-tools')
      return
    end
    local vscode_lldb = rvim.paths.vscode_lldb
    local dap = nil
    local utils = require('user.utils')
    if utils.is_directory(vscode_lldb) then
      local codelldb_path = vscode_lldb .. '/adapter/codelldb'
      local liblldb_path = vscode_lldb .. '/lldb/lib/liblldb.so'
      -- FIX: https://github.com/simrat39/rust-tools.nvim/issues/179
      dap = {
        adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
      }
    end
    local tools = {
      runnables = { use_telescope = true },
      inlay_hints = {
        only_current_line = false,
        only_current_line_autocmd = 'CursorHold',
        show_parameter_hints = false,
        show_variable_name = false,
        parameter_hints_prefix = ' ',
        max_len_align = false,
        max_len_align_padding = 1,
        right_align = false,
        right_align_padding = 7,
        highlight = 'Comment',
      },
      hover_actions = { border = rvim.style.border.rectangle, auto_focus = true },
    }
    local server = {
      -- setting it to false may improve startup time
      standalone = false,
      cmd = { 'rustup', 'run', 'nightly', rvim.paths.mason .. '/bin/rust-analyzer' },
    }
    rust_tools.setup({
      tools = tools,
      dap = dap,
      -- all the opts to send to nvim-lspconfig
      -- these override the defaults set by rust-tools.nvim
      server = vim.tbl_deep_extend('force', config, server),
    })
  end

  M.launch_server(server_name, config)
end

return M
