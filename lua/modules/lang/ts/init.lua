local M = {}

local fts = {
  "lua",
  "javascript",
  "typescript",
  "html"
  -- "typescriptreact",
  -- "css"
  -- "sh",
  -- "c",
  -- "cpp",
  -- "graphql",
  -- "go",
  -- "jsdoc",
  -- "json",
  -- "python",
  -- "rust",
  -- "yaml"
}

local synoff = function()
  local filetypes = vim.fn.join(fts, ",")
  vim.cmd("au FileType " .. filetypes .. " set syn=off")
end

function M.setup()
  -- synoff()
  -- table.remove(fts, 13)
  -- table.remove(fts, 15)
  -- table.insert(fts, 'bash')
  require'nvim-treesitter.configs'.setup {
    highlight = {enable = true},
    autotag = {enable = true},
    indent = {enable = {"javascriptreact"}},
    rainbow = {enable = true, extended_mode = true},
    ensure_installed = fts
  }
  vim.api.nvim_command('set foldmethod=expr')
  vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  vim.api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>',
                          {});
end

return M

