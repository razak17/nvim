rvim.treesitter = rvim.treesitter or {
  install_attempted = {},
}

-- When visiting a file with a type we don't have a parser for, ask me if I want to install it.
function rvim.treesitter.ensure_parser_installed()
  local WAIT_TIME = 6000
  local parsers = require("nvim-treesitter.parsers")
  local lang = parsers.get_buf_lang()
  local fmt = string.format
  if
    parsers.get_parser_configs()[lang]
    and not parsers.has_parser(lang)
         and not rvim.treesitter.install_attempted[lang]
  then
    vim.schedule(function()
      vim.cmd('TSInstall ' .. lang)
      rvim.treesitter.install_attempted[lang] = true
      vim.notify(fmt('Installing Treesitter parser for %s', lang), 'info', {
        title = 'Nvim Treesitter',
        icon = rvim.style.icons.misc.down,
        timeout = WAIT_TIME,
      })
    end)
  end
end

return function()
  rvim.augroup("TSParserCheck", {
    {
      event = "FileType",
      desc = "Treesitter: install missing parsers",
      command = rvim.treesitter.ensure_parser_installed,
    },
  })

  rvim.treesitter = {
    setup = {
      highlight = { enabled = true },
      ensure_installed = { "lua" },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          scope_incremental = "<CR>",
          node_incremental = "<TAB>",
          node_decremental = "<S-TAB>",
        },
      },
      autotag = {
        enable = rvim.plugins.lang.autotag.active,
        filetypes = { "html", "xml", "typescriptreact", "javascriptreact" },
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
    },
  }

  ---Get all filetypes for which we have a treesitter parser installed
  ---@return string[]
  function rvim.treesitter.get_filetypes()
    vim.cmd([[packadd nvim-treesitter]])
    local parsers = require("nvim-treesitter.parsers")
    local configs = parsers.get_parser_configs()
    return vim.tbl_map(function(ft)
      return configs[ft].filetype or ft
    end, parsers.available_parsers())
  end

  local Log = require("user.core.log")
  local status_ok, treesitter_configs = rvim.safe_require("nvim-treesitter.configs")
  if not status_ok then
    Log:debug("Failed to load nvim-treesitter.configs")
    return
  end

  treesitter_configs.setup({
    highlight = {
      enable = rvim.treesitter.setup.highlight.enabled,
      additional_vim_regex_highlighting = true,
    },
    incremental_selection = rvim.treesitter.setup.incremental_selection,
    textobjects = rvim.treesitter.setup.textobjects,
    indent = { enable = { "javascriptreact" } },
    autotag = rvim.treesitter.setup.autotag,
    matchup = { enable = rvim.plugins.lang.matchup.active, disable = { "c", "python" } },
    autopairs = { enable = rvim.plugins.lang.autopairs.active },
    rainbow = rvim.treesitter.setup.rainbow,
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { "BufWrite", "CursorHold" },
    },
    ensure_installed = rvim.treesitter.setup.ensure_installed,
  })

  rvim.nnoremap("R", ":edit | TSBufEnable highlight<CR>", {})

  require("which-key").register({
    ["<leader>Le"] = { ":TSInstallInfo<cr>", "treesitter: info" },
    ["<leader>Lm"] = { ":TSModuleInfo<cr>", "treesitter: module info" },
    ["<leader>Lu"] = { ":TSUpdate<cr>", "treesitter: update" },
  })

  -- Only apply folding to supported files:
  rvim.augroup("TreesitterFolds", {
    {
      event = { "FileType" },
      pattern = rvim.treesitter.get_filetypes(),
      command = "setlocal foldtext=v:lua.folds() foldmethod=expr foldexpr=nvim_treesitter#foldexpr()",
    },
  })
end
