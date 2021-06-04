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
  "lua"
}

vim.cmd [[packadd nvim-treesitter]]
require'nvim-treesitter.configs'.setup {
  highlight = {enable = true},
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
      "darkorchid3"
    }
  },
  matchup = {enable = true, disable = {"c", "python"}},
  ensure_installed = fts
}

vim.api.nvim_set_keymap('n', 'R', ':edit | TSBufEnable highlight<CR>', {});

-- Only apply folding to supported files:
-- r17.augroup("TreesitterFolds", {
--   {
--     events = {"FileType"},
--     targets = require'internal.utils'.get_filetypes(),
--     command = "setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()"
--   }
-- })
