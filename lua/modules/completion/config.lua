local config = {}

function config.nvim_compe()
  require("compe").setup {
    enabled = true,
    debug = false,
    min_length = 1,
    preselect = "always",
    source = {
      nvim_lsp = { kind = "   (LSP)" },
      vsnip = { kind = "   (Snippet)" },
      path = { kind = "   (Path)" },
      buffer = { kind = "   (Buffer)" },
      spell = { kind = "   (Spell)" },
      calc = { kind = "   (Calc)" },
      vim_dadbod_completion = true,
      emoji = { kind = " ﲃ  (Emoji)", filetypes = { "markdown", "text" } },
      tags = true,
      nvim_lua = false,
    },
  }
end

function config.emmet()
  vim.g.user_emmet_complete_tag = 0
  vim.g.user_emmet_install_global = 0
  vim.g.user_emmet_install_command = 0
  vim.g.user_emmet_mode = "i"
end

return config
