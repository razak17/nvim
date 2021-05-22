local M = {}

local filetypes = {
  "lua",
  "html",
  "css",
  "javascript",
  "typescript",
  "tsx",
  "graphql",
  "jsdoc",
  "json",
  "yaml",
  "c",
  "cpp",
  "go",
  "python"
}

local synoff = function(fts)
  local ex = ",javascript,typescriptreact,sh"
  local fts_disable = vim.fn.join(fts, ",")
  vim.cmd("au FileType " .. fts_disable .. ex .. " set syn=off")
end

function M.setup()
  synoff(filetypes)
  table.insert(filetypes, 'tsx')
  table.insert(filetypes, 'bash')
  require'nvim-treesitter.configs'.setup {
    highlight = {enable = true},
    autotag = {enable = true},
    rainbow = {enable = true, extended_mode = true},
    matchup = {enable = true, disable = {"c", "ruby"}},
    ensure_installed = filetypes
  }
  vim.api.nvim_command('set foldmethod=expr')
  vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  vim.api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>',
                          {});
end

return M

