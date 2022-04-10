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
      "http",
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

  local Log = require "user.core.log"
  local status_ok, treesitter_configs = rvim.safe_require "nvim-treesitter.configs"
  if not status_ok then
    Log:debug "Failed to load nvim-treesitter.configs"
    return
  end

  treesitter_configs.setup {
    highlight = {
      enable = rvim.treesitter.highlight.enabled,
      additional_vim_regex_highlighting = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        scope_incremental = "<CR>",
        node_incremental = "<TAB>",
        node_decremental = "<S-TAB>",
      },
    },
    textobjects = {
      lookahead = true,
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aC"] = "@conditional.outer",
          ["iC"] = "@conditional.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["[w"] = "@parameter.inner",
        },
        swap_previous = {
          ["]w"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
      },
      lsp_interop = {
        enable = true,
        border = rvim.style.border.current,
        peek_definition_code = {
          ["<leader>lu"] = "@function.outer",
          ["<leader>lF"] = "@class.outer",
        },
      },
    },
    indent = { enable = { "javascriptreact" } },
    autotag = {
      enable = rvim.plugins.lang.autotag.active,
      filetypes = { "html", "xml", "typescriptreact", "javascriptreact" },
    },
    matchup = { enable = rvim.plugins.lang.matchup.active, disable = { "c", "python" } },
    autopairs = { enable = rvim.plugins.lang.autopairs.active },
    rainbow = {
      enable = rvim.plugins.lang.rainbow.active,
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
    ensure_installed = rvim.treesitter.ensure_installed,
  }

  rvim.nnoremap("R", ":edit | TSBufEnable highlight<CR>", {})

  -- TODO: figure why this does not work
  -- rvim.nnoremap("<leader>Le", ":TSInstallInfo<cr>", {label = 'treesitter: info'})
  -- rvim.nnoremap("<leader>Lm", ":TSModuleInfo<cr>", {label = 'treesitter: module info'})
  -- rvim.nnoremap("<leader>Lu", ":TSUpdate<cr>", {label = 'treesitter: update'})

  require("which-key").register {
    ["<leader>Le"] = { ":TSInstallInfo<cr>", "treesitter: info" },
    ["<leader>Lm"] = { ":TSModuleInfo<cr>", "treesitter: module info" },
    ["<leader>Lu"] = { ":TSUpdate<cr>", "treesitter: update" },
  }

  -- Only apply folding to supported files:
  rvim.augroup("TreesitterFolds", {
    {
      event = { "FileType" },
      pattern = rvim.treesitter.get_filetypes(),
      command = "setlocal foldtext=v:lua.folds() foldmethod=expr foldexpr=nvim_treesitter#foldexpr()",
    },
  })
end
