return function()
  local lsp = require "lsp"
  local lsp_utils = require "lsp.utils"

  local langs = {
    "c",
    "cmake",
    "cpp",
    "docker",
    "elixir",
    "go",
    "graphql",
    "html",
    "json",
    "lua",
    "python",
    "rust",
    "sh",
    "vim",
    "yaml",
    "javascript",
    "javascriptreact",
    "typescript",
  }

  local function setup_servers()
    for _, server in ipairs(langs) do
      lsp.setup(server)
    end
    vim.cmd "doautocmd User LspServersStarted"
  end

  setup_servers()
  require("lsp.handlers").setup()
  require("lsp.hover").setup()
  require("lsp.signs").setup()
  require("lsp.binds").setup()
  lsp_utils.toggle_autoformat()
  lsp_utils.lspLocList()
end
