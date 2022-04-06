local lang = {}

rvim.plugins.lang = {
  -- debug
  dap = { active = true },
  dap_ui = { active = true },
  dap_install = { active = true },
  osv = { active = false },
  nvim_dap_virtual_text = { active = true },
  -- lsp
  lspconfig = { active = true },
  lsp_installer = { active = true },
  fix_cursorhold = { active = true },
  nlsp = { active = true },
  null_ls = { active = true },
  lightbulb = { active = false },
  symbols_outline = { active = false },
  bqf = { active = false },
  trouble = { active = true },
  rust_tools = { active = true },
  schemastore = { active = true },
  lsp_signature = { active = true },
  spellsitter = { active = true },
  go_nvim = { active = false },
  -- treesitter
  treesitter = { active = true },
  playground = { active = true },
  autopairs = { active = true },
  rainbow = { active = true },
  autotag = { active = true },
  matchup = { active = false },
  textobjects = { active = true },
}

local utils = require "user.utils"

-- Debugging
lang["mfussenegger/nvim-dap"] = {
  config = utils.load_conf("user", "dap"),
  disable = not rvim.plugins.lang.dap.active,
}

lang["rcarriga/nvim-dap-ui"] = {
  after = "nvim-dap",
  config = function()
    local dapui = require "dapui"
    dapui.setup()
    rvim.nnoremap("<localleader>dX", dapui.close, "dap-ui: close")
    rvim.nnoremap("<localleader>dO", dapui.toggle, "dap-ui: toggle")
    local dap = require "dap"
    -- NOTE: this opens dap UI automatically when dap starts
    -- dap.listeners.after.event_initialized['dapui_config'] = function()
    --   dapui.open()
    -- end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
  disable = not rvim.plugins.lang.dap_ui.active,
}

lang["Pocco81/DAPInstall.nvim"] = {
  disable = not rvim.plugins.lang.dap_install.active,
}

lang["jbyuki/one-small-step-for-vimkind"] = {
  requires = "nvim-dap",
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>dE", ':lua require"osv".run_this()<CR>')
    nnoremap("<Leader>dl", ':lua require"osv".launch()<CR>')

    require("which-key").register {
      ["<leader>dE"] = "osv run this",
      disable = not rvim.plugins.lang.dap.active,
      ["<leader>dL"] = "osv launch",
    }
  end,
  disable = not rvim.plugins.lang.osv.active,
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
  disable = not rvim.plugins.lang.nvim_dap_virtual_text.active,
}

-- Lsp
lang["williamboman/nvim-lsp-installer"] = {
  requires = {
    "neovim/nvim-lspconfig",
  },
  disable = not rvim.plugins.lang.lsp_installer.active,
}

lang["antoinemadec/FixCursorHold.nvim"] = {
  disable = not rvim.plugins.lang.fix_cursorhold.active,
}

lang["neovim/nvim-lspconfig"] = {
  disable = not rvim.plugins.lang.lspconfig.active,
}

lang["tamago324/nlsp-settings.nvim"] = {
  disable = not rvim.plugins.lang.nlsp.active,
}

lang["jose-elias-alvarez/null-ls.nvim"] = {
  disable = not rvim.plugins.lang.null_ls.active,
}

lang["kosayoda/nvim-lightbulb"] = {
  after = "nvim-lspconfig",
  config = function()
    rvim.augroup("NvimLightbulb", {
      {
        event = { "CursorHold", "CursorHoldI" },
        pattern = { "*" },
        command = function()
          require("nvim-lightbulb").update_lightbulb {
            sign = { enabled = false },
            virtual_text = { enabled = true },
          }
        end,
      },
    })
  end,
  disable = not rvim.plugins.lang.lightbulb.active,
}

lang["simrat39/symbols-outline.nvim"] = {
  after = "nvim-lspconfig",
  cmd = "SymbolsOutline",
  config = function()
    require("symbols-outline").setup { show_guides = true }
  end,
  disable = not rvim.plugins.lang.symbols_outline.active,
}

lang["folke/trouble.nvim"] = {
  after = "nvim-lspconfig",
  requires = "nvim-web-devicons",
  config = function()
    require("which-key").register {
      ["<leader>lq"] = { ":TroubleToggle quickfix<cr>", "trouble: toggle quickfix" },
      ["<leader>ll"] = { ":TroubleToggle loclist<cr>", "trouble: toggle loclist" },
    }
    local u = require "zephyr.util"
    u.plugin("trouble", {
      TroubleNormal = { link = "PanelBackground" },
      TroubleText = { link = "PanelBackground" },
      TroubleIndent = { link = "PanelVertSplit" },
      TroubleFoldIcon = { foreground = "yellow", bold = true },
      TroubleLocation = { foreground = u.get_hl("Comment", "fg") },
    })
    local trouble = require "trouble"
    rvim.nnoremap("]d", function()
      trouble.previous { skip_groups = true, jump = true }
    end)
    rvim.nnoremap("[d", function()
      trouble.next { skip_groups = true, jump = true }
    end)
    trouble.setup { auto_close = true, auto_preview = false, use_diagnostic_signs = true }
  end,
  disable = not rvim.plugins.lang.trouble.active,
}

lang["kevinhwang91/nvim-bqf"] = {
  after = "telescope.nvim",
  config = function()
    require("bqf").setup {
      preview = { border_chars = { "│", "│", "─", "─", "┌", "┐", "└", "┘", "█" } },
    }
  end,
  disable = not rvim.plugins.lang.bqf.active,
}

-- Treesitter
lang["nvim-treesitter/nvim-treesitter"] = {
  branch = vim.fn.has "nvim-0.6" == 1 and "master" or "0.5-compat",
  config = utils.load_conf("lang", "treesitter"),
  disable = not rvim.plugins.lang.treesitter.active,
}

lang["nvim-treesitter/playground"] = {
  event = "VimEnter",
  keys = "<leader>LE",
  module = "nvim-treesitter-playground",
  cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
  setup = function()
    require("which-key").register { ["<leader>LE"] = "treesitter: inspect token" }
  end,
  config = function()
    rvim.nnoremap("<leader>LE", "<Cmd>TSHighlightCapturesUnderCursor<CR>")
  end,
  disable = not rvim.plugins.lang.playground.active,
}

lang["nvim-treesitter/nvim-treesitter-textobjects"] = {
  after = "nvim-treesitter",
  disable = not rvim.plugins.lang.textobjects.active,
}

lang["p00f/nvim-ts-rainbow"] = {
  after = "nvim-treesitter",
  disable = not rvim.plugins.lang.rainbow.active,
}

lang["andymass/vim-matchup"] = {
  after = "nvim-treesitter",
  config = function()
    rvim.nnoremap["<Leader>l?"] = ":<c-u>MatchupWhereAmI?<CR>"
    require("which-key").register {
      ["<leader>l?"] = "where am i",
    }
  end,
  disable = not rvim.plugins.lang.matchup.active,
}

lang["windwp/nvim-ts-autotag"] = {
  after = "nvim-treesitter",
  disable = not rvim.plugins.lang.autotag.active,
}

lang["windwp/nvim-autopairs"] = {
  event = "InsertEnter",
  after = { "telescope.nvim", "nvim-treesitter" },
  config = utils.load_conf("lang", "autopairs"),
  disable = not rvim.plugins.lang.autopairs.active,
}

lang["razak17/rust-tools.nvim"] = {
  disable = not rvim.plugins.lang.rust_tools.active,
}

lang["b0o/schemastore.nvim"] = {
  disable = not rvim.plugins.lang.schemastore.active,
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
  disable = not rvim.plugins.lang.lsp_signature.active,
}

lang["lewis6991/spellsitter.nvim"] = {
  config = function()
    require("spellsitter").setup {
      enable = true,
    }
  end,
  disable = not rvim.plugins.lang.spellsitter.active,
}

lang["ray-x/go.nvim"] = {
  ft = "go",
  -- FIXME: errors out on vim enter
  -- config = function()
  --   local path = require "nvim-lsp-installer.path"
  --   local install_root_dir = path.concat { vim.fn.stdpath "data", "lsp_servers" }
  --   require("go").setup {
  --     gopls_cmd = { install_root_dir .. "/go/gopls" },
  -- }
  -- end,
  disable = not rvim.plugins.lang.go_nvim.active,
}

return lang
