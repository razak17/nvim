local lang = {}

local utils = require "utils"

-- Debug
lang["mfussenegger/nvim-dap"] = {
  event = "BufReadPre",
  config = utils.load_conf("lang", "dap"),
  disable = not rvim.plugin.debug.active,
}

lang["rcarriga/nvim-dap-ui"] = {
  event = "BufReadPre",
  config = utils.load_conf("lang", "dap_ui"),
  disable = not rvim.plugin.debug_ui.active,
}

lang["Pocco81/DAPInstall.nvim"] = {
  event = "BufReadPre",
  config = function()
    vim.cmd [[packadd nvim-dap]]
    local dI = require "dap-install"
    dI.setup { installation_path = vim.g.dap_install_dir }
  end,
  disable = not rvim.plugin.dap_install.active,
}

lang["jbyuki/one-small-step-for-vimkind"] = {
  event = "BufReadPre",
  disable = not rvim.plugin.osv.active,
}

-- Lsp
lang["williamboman/nvim-lsp-installer"] = {
  disable = not rvim.plugin.lsp_installer.active,
}

lang["antoinemadec/FixCursorHold.nvim"] = {
  disable = not rvim.plugin.fix_cursorhold.active,
}

lang["neovim/nvim-lspconfig"] = {
  event = "BufReadPre",
  config = utils.load_conf("lang", "lspconfig"),
  disable = not rvim.plugin.lspconfig.active,
}

lang["tamago324/nlsp-settings.nvim"] = {
  disable = not rvim.plugin.nlsp.active,
}

lang["jose-elias-alvarez/null-ls.nvim"] = {
  disable = not rvim.plugin.null_ls.active,
}

lang["kosayoda/nvim-lightbulb"] = {
  after = "nvim-lspconfig",
  config = function()
    rvim.augroup("NvimLightbulb", {
      {
        events = { "CursorHold", "CursorHoldI" },
        targets = { "*" },
        command = function()
          require("nvim-lightbulb").update_lightbulb {
            sign = { enabled = false },
            virtual_text = { enabled = true },
          }
        end,
      },
    })
  end,
  disable = not rvim.plugin.lightbulb.active,
}

lang["simrat39/symbols-outline.nvim"] = {
  after = "nvim-lspconfig",
  cmd = "SymbolsOutline",
  config = function()
    require("symbols-outline").setup { show_guides = true }
  end,
  disable = not rvim.plugin.symbols_outline.active,
}

lang["folke/trouble.nvim"] = {
  after = "nvim-lspconfig",
  requires = { { "kyazdani42/nvim-web-devicons", opt = true } },
  config = function()
    require("trouble").setup { use_lsp_diagnostic_signs = true }
  end,
  disable = not rvim.plugin.trouble.active,
}

lang["kevinhwang91/nvim-bqf"] = {
  after = "telescope.nvim",
  config = function()
    require("bqf").setup {
      preview = { border_chars = { "│", "│", "─", "─", "┌", "┐", "└", "┘", "█" } },
    }
  end,
  disable = not rvim.plugin.bqf.active,
}

-- Treesitter
lang["nvim-treesitter/nvim-treesitter"] = {
  branch = "0.5-compat",
  after = "telescope.nvim",
  config = utils.load_conf("lang", "treesitter"),
  disable = not rvim.plugin.treesitter.active,
}

lang["nvim-treesitter/playground"] = {
  cmd = "TSPlaygroundToggle",
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<leader>aE", function()
      require("utils").inspect_token()
    end)
  end,
  module = "nvim-treesitter-playground",
  disable = not rvim.plugin.playground.active,
}

lang["p00f/nvim-ts-rainbow"] = { after = "nvim-treesitter", disable = not rvim.plugin.rainbow.active }

lang["andymass/vim-matchup"] = {
  event = "VimEnter",
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>vW", ":<c-u>MatchupWhereAmI?<CR>")
  end,
  after = "nvim-treesitter",
  disable = not rvim.plugin.matchup.active,
}

lang["windwp/nvim-ts-autotag"] = {
  after = "nvim-treesitter",
  event = "InsertLeavePre",
  disable = not rvim.plugin.autotag.active,
}

lang["windwp/nvim-autopairs"] = {
  event = "InsertEnter",
  after = { "telescope.nvim", "nvim-treesitter" },
  config = utils.load_conf("lang", "autopairs"),
  disable = not rvim.plugin.autopairs.active,
}

return lang
