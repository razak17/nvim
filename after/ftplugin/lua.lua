if not rvim or rvim.none then return end

local opt = vim.opt_local

opt.textwidth = 80
opt.spell = true

if not rvim.plugins.enable or rvim.plugins.minimal then return end

opt.spellfile:prepend(
  join_paths(vim.fn.stdpath('config'), 'spell', 'lua.utf-8.add')
)
opt.spelllang = { 'en_gb', 'programming' }
