local api = vim.api
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

local synoff = function()
  local filetypes = vim.fn.join(fts, ",")
  vim.cmd("au FileType " .. filetypes .. " set syn=off")
end

function M.setup()
  synoff()
  table.remove(fts, 16)
  table.insert(fts, 'bash')
  require'nvim-treesitter.configs'.setup {
    highlight = {enable = true},
    indent = {enable = {"javascriptreact"}},
    rainbow = {enable = true, extended_mode = true},
    ensure_installed = fts
  }

  vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

  api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>', {});
end

return M

