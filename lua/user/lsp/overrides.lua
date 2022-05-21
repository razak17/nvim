local M = {}

local lsp_utils = require("user.utils.lsp")
local lsp_manager = require("user.lsp.manager")
local Log = require("user.core.log")

function M.setup(server_name)
  local already_configured = lsp_utils.is_client_active(server_name)
    or lsp_manager.client_is_configured(server_name)
  local config = lsp_manager.resolve_config(server_name, {})

  if already_configured then
    Log:debug(
      string.format("[%q] is already configured. Ignoring repeated setup call.", server_name)
    )
    return
  end

  local servers = require("nvim-lsp-installer.servers")
  local _, server = servers.get_server(server_name)

  -- emmet-ls
  if server_name == "emmet_ls" then
    config = vim.tbl_deep_extend("force", config, {
      filetypes = {
        "html",
        "css",
        "typescriptreact",
        "typescript.tsx",
        "javascriptreact",
        "javascript.jsx",
      },
    })
  end

  -- golangci-lint-ls
  if server_name == "golangci_lint_ls" then
    config = vim.tbl_deep_extend("force", config, {
      init_options = {
        command = {
          "golangci-lint",
          "run",
          "--enable-all",
          "--disable",
          "lll",
          "--out-format",
          "json",
        },
      },
    })
  end

  -- rust_analyzer
  if server_name == "rust_analyzer" then
    M.rust_tools_init(server, config)
  end

  lsp_manager.launch_server(server_name, config)
end

function M.rust_tools_init(server, config)
  local status_ok, rust_tools = rvim.safe_require("rust-tools")
  if not status_ok then
    Log:debug("Failed to load rust-tools")
    return
  end

  local tools = {
    autoSetHints = true,
    runnables = { use_telescope = true },
    inlay_hints = {
      show_parameter_hints = true,
      -- prefix for parameter hints
      parameter_hints_prefix = " ",
      -- prefix for all the other hints (type, chaining)
      other_hints_prefix = " ",
    },
    hover_actions = { auto_focus = true },
  }
  -- Initialize the LSP via rust-tools
  rust_tools.setup({
    tools = tools,
    -- The "server" property provided in rust-tools setup function are the
    -- settings rust-tools will provide to lspconfig during init.            --
    -- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
    -- with the user's own settings (opts).
    server = vim.tbl_deep_extend("force", server:get_default_options(), config),
  })
end

return M
