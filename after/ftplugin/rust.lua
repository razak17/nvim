vim.bo.textwidth = 120
vim.opt_local.spell = true

if rvim.plugin_installed('rust-tools.nvim') then return end

local nnoremap = rvim.nnoremap
local with_desc = function(desc) return { buffer = 0, desc = desc } end
nnoremap('<localleader>rh', '<cmd>RustToggleInlayHints<CR>', with_desc('toggle hints'))
nnoremap('<localleader>rr', '<cmd>RustRunnables<CR>', with_desc('rust-tools: runnables'))
nnoremap('<localleader>rt', '<cmd>lua _CARGO_TEST()<cr>', with_desc('rust-tools: cargo test'))
nnoremap('<localleader>rm', '<cmd>RustExpandMacro<CR>', with_desc('rust-tools: expand cargo'))
nnoremap('<localleader>rc', '<cmd>RustOpenCargo<CR>', with_desc('rust-tools: open cargo'))
nnoremap('<localleader>rp', '<cmd>RustParentModule<CR>', with_desc('rust-tools: parent Module'))
nnoremap('<localleader>rd', '<cmd>RustDebuggables<CR>', with_desc('rust-tools: debuggables'))
nnoremap(
  '<localleader>rv',
  '<cmd>RustViewCrateGraph<CR>',
  with_desc('rust-tools: view crate graph')
)
nnoremap(
  '<localleader>rR',
  "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<CR>",
  with_desc('rust-tools: reload workspace')
)
nnoremap(
  '<localleader>ro',
  '<cmd>RustOpenExternalDocs<CR>',
  with_desc('rust-tools: open external docs')
)
