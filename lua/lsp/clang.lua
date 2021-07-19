local M = {}

M.init = function()
  require'lspconfig'.clangd.setup {
    cmd = {
      core.lsp.binary.clangd,
      "--background-index",
      '--clang-tidy',
      '--completion-style=bundled',
      '--header-insertion=iwyu',
      '--suggest-missing-includes',
      '--cross-file-rename',
    },
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
