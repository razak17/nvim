local tools = {}

local utils = require "user.utils"

tools["sindrets/diffview.nvim"] = {
  event = "BufReadPre",
  config = utils.load_conf("tools", "diff_view"),
  disable = not rvim.plugin.diffview.active,
}

tools["mbbill/undotree"] = {
  disable = not rvim.plugin.undotree.active,
}

tools["ahmedkhalf/project.nvim"] = {
  config = utils.load_conf("tools", "project"),
  disable = not rvim.plugin.project.active,
}

tools["npxbr/glow.nvim"] = {
  run = ":GlowInstall",
  branch = "main",
  disable = not rvim.plugin.glow.active,
}

tools["kkoomen/vim-doge"] = {
  run = ":call doge#install()",
  config = function()
    vim.g.doge_mapping = "<Leader>vD"
  end,
  disable = not rvim.plugin.doge.active,
}

tools["numToStr/FTerm.nvim"] = {
  event = { "BufWinEnter" },
  config = function()
    function _G.__fterm_cmd(key)
      local term = require "FTerm"
      local cmd = term:new { cmd = "gitui" }
      if key == "node" then
        cmd = term:new { cmd = "node" }
      elseif key == "python" then
        cmd = term:new { cmd = "python" }
      elseif key == "lazygit" then
        cmd = term:new { cmd = "lazygit" }
      elseif key == "ranger" then
        cmd = term:new { cmd = "ranger" }
      end
      cmd:toggle()
    end
  end,
  disable = not rvim.plugin.fterm.active,
}

tools["MattesGroeger/vim-bookmarks"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.g.bookmark_no_default_key_mappings = 1
    vim.g.bookmark_sign = ""
  end,
  disable = not rvim.plugin.bookmarks.active,
}

tools["diepm/vim-rest-console"] = {
  event = "VimEnter",
  disable = not rvim.plugin.restconsole.active,
}

tools["iamcco/markdown-preview.nvim"] = {
  run = function()
    vim.fn["mkdp#util#install"]()
  end,
  ft = { "markdown" },
  config = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
  end,
  disable = not rvim.plugin.markdown_preview.active,
}

tools["brooth/far.vim"] = {
  event = { "BufRead" },
  config = function()
    vim.g["far#source"] = "rg"
    vim.g["far#enable_undo"] = 1
  end,
  disable = not rvim.plugin.far.active,
}

tools["Tastyep/structlog.nvim"] = {
  commit = rvim.plugin.commits.structlog,
  disable = not rvim.plugin.structlog.active,
}

tools["AckslD/nvim-neoclip.lua"] = {
  config = function()
    require("neoclip").setup {
      enable_persistent_history = true,
      keys = {
        telescope = {
          i = { select = "<c-p>", paste = "<CR>", paste_behind = "<c-k>" },
          n = { select = "p", paste = "<CR>", paste_behind = "P" },
        },
      },
    }
    local function clip()
      require("telescope").extensions.neoclip.default(require("telescope.themes").get_dropdown())
    end
    require("which-key").register {
      ["<leader>fN"] = { clip, "neoclip: open yank history" },
    }
  end,
  disable = not rvim.plugin.neoclip.active,
}

-- Telescope
tools["razak17/telescope.nvim"] = {
  config = utils.load_conf("tools", "telescope"),
  disable = not rvim.plugin.telescope.active,
}

tools["nvim-telescope/telescope-fzf-native.nvim"] = {
  run = "make",
  disable = not rvim.plugin.telescope_fzf.active,
}

tools["nvim-telescope/telescope-ui-select.nvim"] = {
  disable = not rvim.plugin.telescope_ui_select.active,
}

tools["camgraff/telescope-tmux.nvim"] = {
  disable = not rvim.plugin.telescope_ui_select.active,
}

tools["tami5/sqlite.lua"] = { disable = not rvim.plugin.telescope_frecency.active }

tools["nvim-telescope/telescope-frecency.nvim"] = {
  disable = not rvim.plugin.telescope_frecency.active,
}

tools["nvim-telescope/telescope-dap.nvim"] = {
  disable = not rvim.plugin.telescope_dap.active,
}

tools["nvim-telescope/telescope-file-browser.nvim"] = {
  disable = not rvim.plugin.telescope_file_browser.active,
}

tools["stevearc/dressing.nvim"] = {
  config = function()
    require("dressing").setup {
      input = {
        insert_only = false,
      },
      select = {
        telescope = {
          theme = "dropdown",
        },
      },
    }
  end,
  disable = not rvim.plugin.dressing.active,
}

return tools
