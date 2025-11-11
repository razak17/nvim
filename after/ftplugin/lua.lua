if not ar or ar.none then return end

local fn, opt = vim.fn, vim.opt_local

opt.textwidth = 80
opt.spell = true

opt.spellfile:prepend(
  join_paths(fn.stdpath('config'), 'spell', 'lua.utf-8.add')
)

opt.spelllang:prepend('en')

if ar.has('dial.nvim') and ar.lsp.enable then require('ar.lsp_dial') end
