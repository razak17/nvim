local lang = {}

rvim.plugins.lang = {}

local plug_utils = require("user.utils.plugins")
local conf = require("user.utils").load_conf
local module = "lang"

local enabled = {
  -- debug
  "dap",
  "dap_ui",
  "dap_install",
  "nvim_dap_virtual_text",
  -- lsp
  "lspconfig",
  "lsp_installer",
  "fix_cursorhold",
  "nlsp",
  "null_ls",
  -- treesitter
  "treesitter",
  "playground",
  "autopairs",
  "rainbow",
  "autotag",
  -- Others
  "lightbulb",
  "symbols_outline",
  "rust_tools",
  "schemastore",
  "lsp_signature",
  "spellsitter",
  "go_nvim",
  "textobjects",
  "log_highlighting",
  "vim_kitty",
  "sqls_nvim",
  "matchup",
}
plug_utils.enable_plugins(module, enabled)

local disabled = {
  "osv",
  "trouble",
  "bqf",
}
plug_utils.disable_plugins(module, disabled)

-- Debugging
lang["mfussenegger/nvim-dap"] = {
  config = conf("user", "dap"),
  disable = not rvim.plugins.lang.dap.active,
}

lang["rcarriga/nvim-dap-ui"] = {
  after = "nvim-dap",
  config = function()
    local dapui = require("dapui")
    dapui.setup()
    rvim.nnoremap("<localleader>dX", dapui.close, "dap-ui: close")
    rvim.nnoremap("<localleader>dO", dapui.toggle, "dap-ui: toggle")
    local dap = require("dap")
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

    require("which-key").register({
      ["<leader>dE"] = "osv run this",
      disable = not rvim.plugins.lang.dap.active,
      ["<leader>dL"] = "osv launch",
    })
  end,
  disable = not rvim.plugins.lang.osv.active,
}

lang["theHamsta/nvim-dap-virtual-text"] = {
  after = "nvim-dap",
  config = function()
    require("nvim-dap-virtual-text").setup({
      enabled = true, -- enable this plugin (the default)
      enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
      highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
      all_frames = true, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    })
  end,
  disable = not rvim.plugins.lang.nvim_dap_virtual_text.active,
}

-- Lsp
lang["williamboman/nvim-lsp-installer"] = {
  requires = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    rvim.augroup("LspInstallerConfig", {
      {
        event = "Filetype",
        pattern = "lsp-installer",
        command = function()
          vim.api.nvim_win_set_config(0, { border = rvim.style.border.current })
        end,
      },
    })
  end,
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
  config = function()
    local lightbulb = require("nvim-lightbulb")
    lightbulb.setup({
      ignore = { "null-ls" },
      sign = { enabled = false },
      float = { enabled = true, win_opts = { border = "none" } },
      autocmd = {
        enabled = true,
      },
    })
  end,
  disable = not rvim.plugins.lang.lightbulb.active,
}

lang["simrat39/symbols-outline.nvim"] = {
  config = conf(module, "symbols-outline"),
  disable = not rvim.plugins.lang.symbols_outline.active,
}

lang["folke/trouble.nvim"] = {
  cmd = { "TroubleToggle" },
  requires = "nvim-web-devicons",
  setup = conf(module, "trouble").setup,
  config = conf(module, "trouble").config,
  disable = not rvim.plugins.lang.trouble.active,
}

lang["kevinhwang91/nvim-bqf"] = {
  after = "telescope.nvim",
  config = function()
    require("bqf").setup({
      preview = {
        border_chars = { "│", "│", "─", "─", "┌", "┐", "└", "┘", "█" },
      },
    })
  end,
  disable = not rvim.plugins.lang.bqf.active,
}

-- Treesitter
lang["nvim-treesitter/nvim-treesitter"] = {
  run = ":TSUpdate",
  config = conf(module, "treesitter"),
  disable = not rvim.plugins.lang.treesitter.active,
}

lang["nvim-treesitter/nvim-treesitter-context"] = {
  config = function()
    local hl = require("user.utils.highlights")
    local norm_bg = hl.get_hl("Normal", "bg")
    local dim = hl.alter_color(norm_bg, 25)
    hl.plugin("treesitter-context", {
      ContextBorder = { foreground = dim },
      TreesitterContext = { inherit = "Normal" },
      TreesitterContextLineNumber = { inherit = "LineNr" },
    })
    require("treesitter-context").setup({
      multiline_threshold = 4,
      separator = { "─", "ContextBorder" }, --[[alernatives: ▁ ─ ▄ ]]
      mode = "topline",
    })
  end,
  disable = not rvim.plugins.lang.treesitter.active,
}

lang["nvim-treesitter/playground"] = {
  event = "VimEnter",
  keys = "<leader>LE",
  module = "nvim-treesitter-playground",
  cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
  setup = function()
    require("which-key").register({ ["<leader>LE"] = "treesitter: inspect token" })
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
    require("which-key").register({
      ["<localleader>lm"] = { ":<c-u>MatchupWhereAmI?<CR>", "matchup: where am i" },
    })
  end,
  disable = not rvim.plugins.lang.matchup.active,
}

lang["windwp/nvim-ts-autotag"] = {
  config = function()
    require("nvim-ts-autotag").setup({
      filetypes = { "html", "xml", "typescriptreact", "javascriptreact" },
    })
  end,
  disable = not rvim.plugins.lang.autotag.active,
}

lang["windwp/nvim-autopairs"] = {
  event = "InsertEnter",
  after = { "telescope.nvim", "nvim-treesitter" },
  config = conf(module, "autopairs"),
  disable = not rvim.plugins.lang.autopairs.active,
}

lang["razak17/rust-tools.nvim"] = {
  disable = not rvim.plugins.lang.rust_tools.active,
}

lang["b0o/schemastore.nvim"] = {
  disable = not rvim.plugins.lang.schemastore.active,
}

lang["ray-x/lsp_signature.nvim"] = {
  event = "InsertEnter",
  config = function()
    require("lsp_signature").setup({
      debug = false,
      log_path = rvim.get_cache_dir() .. "/lsp_signature.log",
      bind = true,
      fix_pos = false,
      auto_close_after = 15,
      hint_enable = false,
      handler_opts = { border = rvim.style.border.current },
      toggle_key = "<C-K>",
      select_signature_key = "<M-N>",
    })
  end,
  disable = not rvim.plugins.lang.lsp_signature.active,
}

lang["lewis6991/spellsitter.nvim"] = {
  config = function()
    require("spellsitter").setup({
      enable = true,
    })
  end,
  disable = not rvim.plugins.lang.spellsitter.active,
}

lang["ray-x/go.nvim"] = {
  ft = "go",
  config = conf(module, "go"),
  disable = not rvim.plugins.lang.go_nvim.active,
}

lang["mtdl9/vim-log-highlighting"] = {
  disable = not rvim.plugins.lang.log_highlighting.active,
}

lang["fladson/vim-kitty"] = {
  disable = not rvim.plugins.lang.vim_kitty.active,
}

lang["nanotee/sqls.nvim"] = {
  disable = not rvim.plugins.lang.sqls_nvim.active,
}

return lang
