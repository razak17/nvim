local config = {}

function config.which_key()
  require 'keymap.which_key'
end

function config.nvim_compe()
  require('compe').setup {
    enabled = true,
    min_length = 1,
    preselect = "always",
    source = {
      buffer = {kind = "   (Buffer)"},
      path = {kind = "   (Path)"},
      spell = {kind = "   (Spell)"},
      calc = {kind = "   (Calc)"},
      vsnip = {kind = "   (Snippet)"},
      nvim_lsp = {kind = "   (LSP)"},
      vim_dadbod_completion = true,
      emoji = {kind = " ﲃ  (Emoji)", filetypes = {"markdown", "text"}},
      tags = true,
      nvim_lua = false
    }
  }
end

function config.vim_vsnip()
  local G = require 'core.global'
  vim.g["vsnip_snippet_dir"] = G.vim_path .. "/snippets"
end

function config.emmet()
  vim.g.user_emmet_complete_tag = 0
  vim.g.user_emmet_install_global = 0
  vim.g.user_emmet_install_command = 0
  vim.g.user_emmet_mode = 'i'
end

function config.telescope_nvim()
  require('modules.completion.telescope')
end

return config
