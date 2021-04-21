local config = {}

function config.nvim_compe()
  require('compe').setup {
    enabled = true,
    debug = false,
    min_length = 2,
    preselect = "always",
    allow_prefix_unmatch = false,
    source = {
      buffer = true,
      path = true,
      spell = true,
      tags = true,
      calc = true,
      vsnip = true,
      nvim_lsp = true,
      treesitter = true,
      nvim_lua = true
    }
  }
end

function config.vim_vsnip()
  local G = require 'core.global'
  vim.g["vsnip_snippet_dir"] = G.vim_path .. "/snippets"
end

function config.emmet()
  vim.g.user_emmet_leader_key = '<C-y>'
  vim.g.user_emmet_complete_tag = 0
  vim.g.user_emmet_install_global = 0
  vim.g.user_emmet_mode = 'i'
  vim.cmd('autocmd FileType html,css EmmetInstall')
end

function config.telescope_nvim()
  require('modules.completion.telescope')
end

return config
