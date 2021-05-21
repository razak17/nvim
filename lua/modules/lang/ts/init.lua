local api = vim.api
local M = {}

local fts = {
  "c",
  "cpp",
  "css",
  "graphql",
  "go",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "python",
  "rust",
  "sh",
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
  table.remove(fts, 13)
  table.insert(fts, 'bash')
  require'nvim-treesitter.configs'.setup {
    highlight = {enable = true},
    autotag = {enable = true},
    indent = {enable = {"javascriptreact"}},
    rainbow = {enable = true, extended_mode = true},
    ensure_installed = fts
  }

  vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

  api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>', {});
end

return M

