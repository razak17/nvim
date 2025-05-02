if not ar or ar.none then return end

local fn, opt = vim.fn, vim.opt_local

opt.textwidth = 80
opt.spell = true

if not ar.plugins.enable or ar.plugins.minimal then return end

opt.spellfile:prepend(
  join_paths(fn.stdpath('config'), 'spell', 'lua.utf-8.add')
)
opt.spelllang = { 'en_gb', 'programming' }

local is_available = ar.is_available

if is_available('dial.nvim') and ar.lsp.enable then require('ar.lsp_dial') end
