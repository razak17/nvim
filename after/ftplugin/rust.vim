lua << EOF
local lsp_installer = require "nvim-lsp-installer"

local Log = require "user.core.log"
local status_ok, rust_tools = rvim.safe_require "rust-tools"
if not status_ok then
  Log:debug "Failed to load rust-tools"
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

lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = require("user.lsp").global_on_attach,
    on_init = require("user.lsp").global_on_init,
    on_exit = require("user.lsp").global_on_exit,
    capabilities = require("user.lsp").global_capabilities(),
  }

  if server.name == "rust_analyzer" then
    local servers = require "nvim-lsp-installer.servers"
    local server_available, _ = servers.get_server(server)

    if not server_available then
      -- Initialize rust_analyzer
      server:setup(opts)

      -- Initialize the LSP via rust-tools
      rust_tools.setup {
        tools = tools,
        -- The "server" property provided in rust-tools setup function are the
        -- settings rust-tools will provide to lspconfig during init.            --
        -- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
        -- with the user's own settings (opts).
        server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
      }
      server:attach_buffers()
    end
  end
end)
EOF
