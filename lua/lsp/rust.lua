local M = {}

M.init = function()
  if rvim.check_lsp_client_active "rust_analyzer" then
    return
  end
  if rvim.lang.lsp.rust_tools then
    require("rust-tools").setup({
      tools = {
        autoSetHints = true,
        hover_with_actions = true,
        runnables = {use_telescope = true},
        inlay_hints = {
          show_parameter_hints = true,
          parameter_hints_prefix = "<-",
          other_hints_prefix = "=>",
          max_len_align = false,
          max_len_align_padding = 1,
          right_align = false,
          right_align_padding = 7,
        },
        hover_actions = {
          border = {
            {"╭", "FloatBorder"},
            {"─", "FloatBorder"},
            {"╮", "FloatBorder"},
            {"│", "FloatBorder"},
            {"╯", "FloatBorder"},
            {"─", "FloatBorder"},
            {"╰", "FloatBorder"},
            {"│", "FloatBorder"},
          },
        },
      },
      server = {
        cmd = {rvim.lang.lsp.binary.rust},
        capabilities = rvim.lang.lsp.capabilities,
        on_attach = rvim.lang.lsp.on_attach,
      },
    })
  else
    require'lspconfig'.rust_analyzer.setup {
      cmd = {rvim.lang.lsp.binary.rust},
      -- checkOnSave = {command = "clippy"},
      capabilities = rvim.lang.lsp.capabilities,
      on_attach = rvim.lang.lsp.on_attach,
      filetypes = {"rust"},
      root_dir = require("lspconfig.util").root_pattern("Cargo.toml", "rust-project.json"),
    }
  end
end

M.format = function()
  local filetype = {}
  filetype["rust"] = {
    function()
      return {exe = "rustfmt", args = {"--emit=stdout", "--edition=2018"}, stdin = true}
    end,
  }

  require("formatter.config").set_defaults {logging = false, filetype = filetype}
end

M.lint = function()
  -- TODO: implement linters (if applicable)
  return "No linters configured!"
end

return M
