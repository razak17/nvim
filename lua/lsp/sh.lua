local M = {}

M.init = function()
  if rvim.check_lsp_client_active "bashls" then
    return
  end
  require'lspconfig'.bashls.setup {
    cmd = {rvim.lang.lsp.binary.sh, "start"},
    cmd_env = {GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"},
    filetypes = {"sh", "zsh"},
    capabilities = rvim.lang.lsp.capabilities,
    on_attach = rvim.lang.lsp.on_attach,
  }
end

M.format = function()
  local filetype = {}
  filetype["sh"] = {
    function()
      return {exe = "shfmt", args = {"-w"}, stdin = false, tempfile_prefix = ".formatter"}
    end,
  }

  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.lint = function()
  local linters = {"shellcheck"}
  require("lint").linters_by_ft = {sh = linters}
end

return M
