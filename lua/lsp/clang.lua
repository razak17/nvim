local M = {}

M.init = function()
  if core.check_lsp_client_active "clangd" then
    return
  end
  local clangd_flags = {
    "--background-index",
    -- '--clang-tidy',
    '--completion-style=bundled',
    '--header-insertion=iwyu',
    '--cross-file-rename',
  }
  require'lspconfig'.clangd.setup {
    cmd = {core.lsp.binary.clangd, unpack(clangd_flags)},
    init_options = {
      clangdFileStatus = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticHighlighting = true,
    },
    capabilities = core.lsp.capabilities,
    on_attach = core.lsp.on_attach,
  }
end

M.format = function()
  local shared_config = {
    function()
      return {exe = "clang-format", args = {}, stdin = true, cwd = vim.fn.expand "%:h:p"}
    end,
  }
  local filetype = {}
  filetype["c"] = shared_config
  filetype["cpp"] = shared_config
  filetype["objc"] = shared_config

  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.lint = function()
  local linters = {"cppcheck", "clangtidy"}
  require("lint").linters_by_ft = {c = linters, cpp = linters}
end

return M
