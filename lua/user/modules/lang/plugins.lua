local lang = {}

local utils = require "user.utils"

-- Debugging
lang["mfussenegger/nvim-dap"] = {
  config = utils.load_conf("user", "dap"),
  disable = not rvim.plugin.dap.active,
}

lang["Pocco81/DAPInstall.nvim"] = {
  disable = not rvim.plugin.dap_install.active,
}

lang["jbyuki/one-small-step-for-vimkind"] = {
  requires = "nvim-dap",
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>dE", ':lua require"osv".run_this()<CR>')
    nnoremap("<Leader>dl", ':lua require"osv".launch()<CR>')
  end,
  disable = not rvim.plugin.osv.active,
}

lang["theHamsta/nvim-dap-virtual-text"] = {
  config = function()
    require("nvim-dap-virtual-text").setup {
      enabled = true, -- enable this plugin (the default)
      enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
      highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
      all_frames = true, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    }
  end,
  disable = not rvim.plugin.nvim_dap_virtual_text.active,
}

-- Lsp
lang["williamboman/nvim-lsp-installer"] = {
  requires = {
    "neovim/nvim-lspconfig",
  },
  commit = rvim.plugin.commits.nvim_lsp_installer,
  disable = not rvim.plugin.lsp_installer.active,
}

lang["antoinemadec/FixCursorHold.nvim"] = {
  disable = not rvim.plugin.fix_cursorhold.active,
}

lang["neovim/nvim-lspconfig"] = {
  commit = rvim.plugin.commits.nvim_lspconfig,
  disable = not rvim.plugin.lspconfig.active,
}

lang["tamago324/nlsp-settings.nvim"] = {
  disable = not rvim.plugin.nlsp.active,
}

lang["jose-elias-alvarez/null-ls.nvim"] = {
  commit = rvim.plugin.commits.null_ls,
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
    require("which-key").register {
      ["<leader>vx"] = {
        name = "+Trouble",
        d = { ":TroubleToggle lsp_document_diagnostics<cr>", "document" },
        q = { ":TroubleToggle quickfix<cr>", "quickfix" },
        l = { ":TroubleToggle loclist<cr>", "loclist" },
        r = { ":TroubleToggle lsp_references<cr>", "references" },
        w = { ":TroubleToggle lsp_workspace_diagnostics<cr>", "workspace" },
      },
    }
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
  branch = vim.fn.has "nvim-0.6" == 1 and "master" or "0.5-compat",
  config = utils.load_conf("lang", "treesitter"),
  commit = rvim.plugin.commits.nvim_treesitter,
  disable = not rvim.plugin.treesitter.active,
}

lang["nvim-treesitter/playground"] = {
  event = "VimEnter",
  module = "nvim-treesitter-playground",
  disable = not rvim.plugin.playground.active,
}

lang["p00f/nvim-ts-rainbow"] = {
  after = "nvim-treesitter",
  disable = not rvim.plugin.rainbow.active,
}

lang["andymass/vim-matchup"] = {
  after = "nvim-treesitter",
  disable = not rvim.plugin.matchup.active,
}

lang["windwp/nvim-ts-autotag"] = {
  after = "nvim-treesitter",
  disable = not rvim.plugin.autotag.active,
}

lang["windwp/nvim-autopairs"] = {
  event = "InsertEnter",
  after = { "telescope.nvim", "nvim-treesitter" },
  config = utils.load_conf("lang", "autopairs"),
  commit = rvim.plugin.commits.autopairs,
  disable = not rvim.plugin.autopairs.active,
}

lang["razak17/rust-tools.nvim"] = {
  disable = not rvim.plugin.rust_tools.active,
}

lang["b0o/schemastore.nvim"] = {
  commit = rvim.plugin.commits.schemastore,
  disable = not rvim.plugin.schemastore.active,
}

lang["ray-x/lsp_signature.nvim"] = {
  config = function()
    require("lsp_signature").setup {
      debug = false,
      log_path = rvim.get_cache_dir() .. "/lsp_signature.log", -- log dir when debug is on
      bind = true,
      fix_pos = false,
      auto_close_after = 15, -- close after 15 seconds
      hint_enable = false,
      handler_opts = { border = "rounded" },
    }
  end,
  disable = not rvim.plugin.lsp_signature.active,
}

lang["lewis6991/spellsitter.nvim"] = {
  config = function()
    require("spellsitter").setup {
      enable = { "markdown" },
    }
  end,
  disable = not rvim.plugin.spellsitter.active,
}

return lang
