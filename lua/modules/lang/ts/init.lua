local api = vim.api
local ts = require 'nvim-treesitter.ts_utils'
local tslocals = require 'nvim-treesitter.locals'
local M = {}

local fts = {
  "c",
  "cpp",
  "css",
  "erlang",
  "graphql",
  "go",
  "haskell",
  "html",
  "javascript",
  "jsdoc",
  "julia",
  "json",
  "lua",
  "python",
  "rust",
  "sh",
  "toml",
  "tsx",
  "typescript",
  "yaml"
}

function _G.tsMatchit()
  local node = tslocals.containing_scope(ts.get_node_at_cursor(0), 0, true)
  local _, lnum, col = unpack(vim.fn.getcurpos())
  lnum = lnum - 1
  col = col - 1
  local srow, scol, erow, ecol = node:range()

  if lnum - srow < erow - lnum then
    api.nvim_win_set_cursor(0, {erow + 1, ecol})
  else
    api.nvim_win_set_cursor(0, {srow + 1, scol})
  end
end

function M.matchit()
  api.nvim_buf_set_keymap(0, 'n', '%', ':lua tsMatchit()<CR>', {silent = true})
end

local synoff = function()
  local filetypes = vim.fn.join(fts, ",")
  vim.cmd("au FileType " .. filetypes .. " set syn=off")
  vim.cmd("au FileType " .. filetypes ..
              " lua require'modules.lang.ts'.matchit()")
end

table.remove(fts, 16)
table.insert(fts, 'bash')

function M.setup()
  synoff()
  require'nvim-treesitter.configs'.setup {
    ensure_installed = fts,
    highlight = {enable = true},
    rainbow = {enable = true, extended_mode = true},
    indent = {enable = true}
    -- autotag = {enable = true, filetypes = {"html", "xml"}}
  }

  vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

  api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>', {});
end

return M

