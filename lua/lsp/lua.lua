local M = {}

M.init = function()
  if core.check_lsp_client_active "sumneko_lua" then
    return
  end
  require'lspconfig'.sumneko_lua.setup {
    cmd = {core.lsp.binary.lua, "-E", core.__sumneko_root_path .. "/main.lua"},
    capabilities = core.lsp.capabilities,
    on_attach = core.lsp.on_attach,
    settings = {
      Lua = {
        runtime = {version = "LuaJIT", path = vim.split(package.path, ';')},
        diagnostics = {globals = {"vim", "packer_plugins", "core"}},
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 1000,
        },
      },
    },
  }
end

M.format = function()
  local filetype = {}
  filetype["lua"] = {
    function()
      -- return {exe = "stylua", args = {}, stdin = false, tempfile_prefix = ".formatter"}
      return {
        exe = "lua-format",
        args = {"lua-format -i -c" .. vim.fn.stdpath('config') .. "/.lua-format"},
        stdin = false,
        tempfile_prefix = ".formatter",
      }

    end,
  }
  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.lint = function()
  require("lint").linters_by_ft = {lua = {"luacheck"}}
end

return M
