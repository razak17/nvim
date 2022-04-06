local M = {}

local lsp_installer = require "nvim-lsp-installer"
local lsp_manager = require "user.lsp.manager"
local Log = require "user.core.log"

function M.setup(server_name)
  local already_configured = require("user.utils.lsp").is_client_active(server_name)
    or lsp_manager.client_is_configured(server_name)
  local config = lsp_manager.resolve_config(server_name)

  if already_configured then
    Log:debug(
      string.format("[%q] is already configured. Ignoring repeated setup call.", server_name)
    )
    return
  end

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

    require("lspconfig")[server_name].setup(config)
    lsp_manager.buf_try_add(server_name)
  end

  -- rust_analyzer
  if server_name == "rust_analyzer" then
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
      if server.name == "rust_analyzer" then
        local servers = require "nvim-lsp-installer.servers"
        local server_available, _ = servers.get_server(server)

        if not server_available then
          -- Initialize rust_analyzer
          server:setup(config)

          -- Initialize the LSP via rust-tools
          rust_tools.setup {
            tools = tools,
            -- The "server" property provided in rust-tools setup function are the
            -- settings rust-tools will provide to lspconfig during init.            --
            -- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
            -- with the user's own settings (opts).
            server = vim.tbl_deep_extend("force", server:get_default_options(), config),
          }
          server:attach_buffers()
        end
      end
    end)
  end
end

return M
