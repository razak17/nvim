local completion = {}

rvim.plugins.completion = {
  which_key = { active = true },
  plenary = { active = true },
  popup = { active = true },
  cmp = { active = true },
  vsnip = { active = true },
  emmet = { active = true },
  friendly_snippets = { active = true },
}

local utils = require "user.utils"

completion["folke/which-key.nvim"] = {
  config = utils.load_conf("completion", "which_key"),
  disable = not rvim.plugins.completion.which_key.active,
}

completion["mattn/emmet-vim"] = {
  config = function()
    vim.g.user_emmet_complete_tag = 0
    vim.g.user_emmet_install_global = 0
    vim.g.user_emmet_install_command = 0
    vim.g.user_emmet_mode = "i"
    vim.cmd "autocmd FileType html,css EmmetInstall"
  end,
  disable = not rvim.plugins.completion.emmet.active,
}

completion["hrsh7th/nvim-cmp"] = {
  module = "cmp",
  event = "InsertEnter",
  requires = {
    { "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" },
    { "hrsh7th/cmp-vsnip", after = "nvim-cmp" },
    { "hrsh7th/cmp-buffer", after = "nvim-cmp" },
    { "hrsh7th/cmp-path", after = "nvim-cmp" },
    { "f3fora/cmp-spell", after = "nvim-cmp" },
    { "hrsh7th/cmp-emoji", after = "nvim-cmp" },
    { "octaltree/cmp-look", after = "nvim-cmp" },
    { "tzachar/cmp-tabnine", run = "./install.sh", after = "nvim-cmp" },
    {
      "petertriho/cmp-git",
      after = "nvim-cmp",
      config = function()
        require("cmp_git").setup {
          filetypes = { "gitcommit", "NeogitCommitMessage" },
        }
      end,
    },
  },
  config = utils.load_conf("completion", "cmp"),
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/vim-vsnip"] = {
  config = function()
    vim.g.vsnip_snippet_dir = rvim.snippets_dir

    local xmap = rvim.xmap
    xmap("<C-x>", "<Plug>(vsnip-cut-text)")
    xmap("<C-l>", "<Plug>(vsnip-select-text)")
    rvim.imap(
      "<C-l>",
      "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
      { expr = true }
    )
    rvim.smap(
      "<C-l>",
      "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
      { expr = true }
    )

    require("which-key").register { ["<leader>S"] = { ":VsnipOpen<CR> 1<CR><CR>", "edit snippet" } }
  end,
  disable = not rvim.plugins.completion.vsnip.active,
}

completion["rafamadriz/friendly-snippets"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.friendly_snippets.active,
}

completion["nvim-lua/plenary.nvim"] = { disable = not rvim.plugins.completion.plenary.active }

completion["nvim-lua/popup.nvim"] = { disable = not rvim.plugins.completion.popup.active }

return completion
