local M = {}

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
  "python"
}

local synoff = function(fts_disabled)
  local ex = ",javascript,typescriptreact,sh"
  local fts_synoff = vim.fn.join(fts_disabled, ",")
  vim.cmd("au FileType " .. fts_synoff .. ex .. " set syn=off")
end

function M.setup()
  synoff(fts)
  table.insert(fts, 'tsx')
  table.insert(fts, 'bash')
  require'nvim-treesitter.configs'.setup {
    highlight = {enable = true},
    autotag = {enable = true},
    rainbow = {enable = true, extended_mode = true},
    matchup = {enable = true, disable = {"c", "python"}},
    ensure_installed = fts
  }
  vim.api.nvim_command('set foldmethod=expr')
  vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  vim.api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>',
                          {});
end

return M
