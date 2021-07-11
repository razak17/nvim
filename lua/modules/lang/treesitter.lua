--- Global treesitter object containing treesitter related utilities
core.ts = {}

local fts = {
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
}

---Get all filetypes for which we have a treesitter parser installed
---@return string[]
function core.ts.get_filetypes()
  vim.cmd [[packadd nvim-treesitter]]
  local parsers = require("nvim-treesitter.parsers")
  local configs = parsers.get_parser_configs()
  return vim.tbl_map(function(ft) return configs[ft].filetype or ft end,
    parsers.available_parsers())
end

require'nvim-treesitter.configs'.setup {
  highlight = {enable = true},
  indent = {enable = true},
  autotag = {enable = true},
  autopairs = {enable = true},
  rainbow = {
    enable = true,
    extended_mode = true,
    disable = {"lua", "json", "c", "cpp"},
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
    lint_events = {"BufWrite", "CursorHold"},
  },
  -- matchup = {enable = true, disable = {"c", "python"}},
  ensure_installed = fts,
}

vim.api.nvim_set_keymap('n', 'R', ':edit | TSBufEnable highlight<CR>', {});

-- Only apply folding to supported files:
core.augroup("TreesitterFolds", {
  {
    events = {"FileType"},
    targets = core.ts.get_filetypes(),
    command = "setlocal foldtext=v:lua.folds() foldmethod=expr foldexpr=nvim_treesitter#foldexpr()",
  },
})

