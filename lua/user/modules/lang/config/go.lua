return function()
  local path = require("nvim-lsp-installer.core.path")
  local install_root_dir = path.concat({ vim.call("stdpath", "data"), "lsp_servers" })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local lsp_ok, cmp_nvim_lsp = rvim.safe_require("cmp_nvim_lsp")
  if lsp_ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
  end

  require("go").setup({
    gopls_cmd = { install_root_dir .. "/go/gopls" },
    max_line_len = 100,
    goimport = "gopls",
    lsp_cfg = {
      capabilities = capabilities,
      settings = {
        gopls = {
          codelenses = {
            generate = true,
            gc_details = false,
            test = true,
            tidy = true,
          },
          analyses = {
            unusedparams = true,
          },
        },
      },
    },
    lsp_gofumpt = true,
    lsp_keymaps = false,
    lsp_on_attach = require("user.lsp").global_on_attach,
    lsp_diag_virtual_text = {
      space = 0,
      prefix = rvim.style.icons.misc.bug,
    },
    dap_debug_keymap = false,
    textobjects = false,
  })
end
