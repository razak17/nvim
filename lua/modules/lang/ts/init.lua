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
  "cpp",
  "lua",
  "rust",
  "python",
  "bash"
}

local get_filetypes = function()
  local parsers = require("nvim-treesitter.parsers")
  local configs = parsers.get_parser_configs()
  return vim.tbl_map(function(ft)
    return configs[ft].filetype or ft
  end, parsers.available_parsers())
end

vim.cmd [[packadd nvim-treesitter]]
require'nvim-treesitter.configs'.setup {
  highlight = {enable = true},
  autotag = {enable = true},
  autopairs = {enable = true},
  rainbow = {
    enable = true,
    extended_mode = true,
    disable = {"lua", "json"},
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

local fold =
    "set foldmethod=expr foldtext=v:lua.folds() foldexpr=nvim_treesitter#foldexpr()"
local syn_off = "set syntax=off"
-- TODO
-- local highlight = ":edit | TSBufEnable highlight<CR>"

local targets = get_filetypes()
local filetypes = table.concat(targets, ",")

-- vim.cmd [[edit | TSBufEnable highlight]]
vim.cmd(string.format("autocmd FileType %s %s", filetypes, syn_off))
vim.cmd(string.format("autocmd FileType %s %s", filetypes, fold))
-- vim.cmd(string.format("autocmd FileType %s %s", filetypes, highlight))

vim.api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>',
                        {});
