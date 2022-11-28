if not rvim.plugin_installed('typescript.nvim') then return end

require('typescript').setup({
  disable_commands = false,
  debug = false,
  go_to_source_definition = {
    fallback = true,
  },
})

local nnoremap = rvim.nnoremap
local with_desc = function(desc) return { buffer = 0, desc = desc } end

nnoremap('<localleader>tr', '<cmd>TypescriptRenameFile<CR>', with_desc('typescript: rename file'))
nnoremap('<localleader>tf', '<cmd>TypescriptFixAll<CR>', with_desc('typescript: fix all'))
nnoremap(
  '<localleader>tia',
  '<cmd>TypescriptAddMissingImports<CR>',
  with_desc('typescript: add missing')
)
nnoremap(
  '<localleader>tio',
  '<cmd>TypescriptOrganizeImports<CR>',
  with_desc('typescript: organize')
)
nnoremap(
  '<localleader>tix',
  '<cmd>TypescriptRemoveUnused<CR>',
  with_desc('typescript: remove unused')
)
