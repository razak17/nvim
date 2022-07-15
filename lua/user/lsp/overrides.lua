local M = {}

local utils = require('user.utils')
local lsp_utils = require('user.utils.lsp')
local lsp_manager = require('user.lsp.manager')
local Log = require('user.core.log')

function M.setup(server_name)
  local already_configured = lsp_utils.is_client_active(server_name)
    or lsp_manager.client_is_configured(server_name)
  local config = lsp_manager.resolve_config(server_name, {})

  if already_configured then
    Log:debug(
      string.format('[%q] is already configured. Ignoring repeated setup call.', server_name)
    )
    return
  end

  local servers = require('nvim-lsp-installer.servers')
  local _, server = servers.get_server(server_name)

  -- emmet-ls
  if server_name == 'emmet_ls' then
    config = vim.tbl_deep_extend('force', config, {
      filetypes = {
        'html',
        'css',
        'typescriptreact',
        'typescript.tsx',
        'javascriptreact',
        'javascript.jsx',
      },
    })
  end
  -- rust_analyzer
  if server_name == 'rust_analyzer' then M.rust_tools_init(config) end

  -- sqlls
  if server_name == 'sqlls' then
    server_name = 'sqls'
    config = {
      on_attach = function(client, bufnr) require('sqls').on_attach(client, bufnr) end,
    }
  end

  -- Initialize Server
  lsp_manager.launch_server(server_name, config)
end

function M.rust_tools_init(config)
  local status_ok, rust_tools = rvim.safe_require('rust-tools')
  if not status_ok then
    Log:debug('Failed to load rust-tools')
    return
  end

  local vscode_lldb = rvim.paths.vscode_lldb
  local dap = nil

  if utils.is_directory(vscode_lldb) then
    local codelldb_path = vscode_lldb .. '/adapter/codelldb'
    local liblldb_path = vscode_lldb .. '/lldb/lib/liblldb.so'
    -- FIX: https://github.com/simrat39/rust-tools.nvim/issues/179
    dap = {
      adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
    }
  end

  local server = {
    -- setting it to false may improve startup time
    standalone = false,
  }
  local tools = {
    runnables = { use_telescope = true },
    hover_actions = { border = rvim.style.border.rectangle, auto_focus = true },
  }
  -- Initialize the LSP via rust-tools
  rust_tools.setup({
    tools = tools,
    dap = dap,
    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    server = vim.tbl_deep_extend('force', config, server),
  })
end

return M
