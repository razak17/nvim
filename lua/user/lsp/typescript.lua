if not rvim.plugin_loaded('typescript.nvim') then return end

local ts = require('typescript')

ts.setup({
  disable_commands = false,
  debug = false,
  go_to_source_definition = { fallback = true },
})

local nnoremap = rvim.nnoremap
local with_desc = function(desc) return { buffer = 0, desc = desc } end
local actions = ts.actions

nnoremap('<localleader>tr', '<cmd>TypescriptRenameFile<CR>', with_desc('typescript: rename file'))
nnoremap('<localleader>tf', actions.fixAll, with_desc('typescript: fix all'))
nnoremap('<localleader>tia', actions.addMissingImports, with_desc('typescript: add missing'))
nnoremap('<localleader>tio', actions.organizeImports, with_desc('typescript: organize'))
nnoremap('<localleader>tix', actions.removeUnused, with_desc('typescript: remove unused'))
