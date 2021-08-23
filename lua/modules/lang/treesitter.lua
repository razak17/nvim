return function()
  rvim.treesitter = {
    ensure_installed = {
      "html",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "graphql",
      "jsdoc",
      "json",
      "yaml",
      "go",
      "c",
      "dart",
      "cpp",
      "rust",
      "python",
      "bash",
      "lua",
    },
    highlight = { enabled = true },
  }

  ---Get all filetypes for which we have a treesitter parser installed
  ---@return string[]
  function rvim.treesitter.get_filetypes()
    vim.cmd [[packadd nvim-treesitter]]
    local parsers = require "nvim-treesitter.parsers"
    local configs = parsers.get_parser_configs()
    return vim.tbl_map(function(ft)
      return configs[ft].filetype or ft
    end, parsers.available_parsers())
  end

  require("nvim-treesitter.configs").setup {
    highlight = { enable = rvim.treesitter.highlight.enabled },
    indent = { enable = { "javascriptreact" } },
    autotag = { enable = rvim.plugin.autotag.active },
    autopairs = { enable = rvim.plugin.autopairs.active },
    rainbow = {
      enable = rvim.plugin.rainbow.active,
      extended_mode = true,
      max_file_lines = 1000,
      disable = { "lua", "json", "c", "cpp", "html" },
      colors = {
        "royalblue3",
        "darkorange3",
        "seagreen3",
        "firebrick",
        "darkorchid3",
      },
    },
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { "BufWrite", "CursorHold" },
    },
    matchup = { enable = true, disable = { "c", "python" } },
    ensure_installed = rvim.treesitter.ensure_installed,
  }

  vim.api.nvim_set_keymap("n", "R", ":edit | TSBufEnable highlight<CR>", {})

  -- Mappings
  local nnoremap = rvim.nnoremap
  nnoremap("<Leader>Ie", ":TSInstallInfo<CR>")
  nnoremap("<Leader>Iu", ":TSUpdate<CR>")

  -- Only apply folding to supported files:
  rvim.augroup("TreesitterFolds", {
    {
      events = { "FileType" },
      targets = rvim.treesitter.get_filetypes(),
      command = "setlocal foldtext=v:lua.folds() foldmethod=expr foldexpr=nvim_treesitter#foldexpr()",
    },
  })
end
