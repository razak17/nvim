return function()
  local path = require "nvim-lsp-installer.path"
  local install_root_dir = path.concat { vim.fn.stdpath "data", "lsp_servers" }
  require("go").setup {
    gopls_cmd = { install_root_dir .. "/go/gopls" },
    max_line_len = 100,
    goimport = "gopls", -- NOTE: using goimports comes with unintended formatting consequences
    lsp_codelens = false,
    lsp_cfg = {
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
    lsp_gofumpt = true,
    lsp_keymaps = false,
    lsp_on_attach = require("user.lsp").global_on_attach,
    lsp_diag_virtual_text = {
      space = 0,
      prefix = rvim.style.icons.misc.bug,
    },
    dap_debug_keymap = false,
    textobjects = false,
  }
end
