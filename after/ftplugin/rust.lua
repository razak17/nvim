vim.bo.textwidth = 120

if not rvim then return end

local nnoremap = rvim.nnoremap
if rvim.plugin_installed('rust-tools.nvim') then
  nnoremap('<localleader>h', '<cmd>RustToggleInlayHints<Cr>', 'toggle hints')
  nnoremap('<localleader>rr', '<cmd>RustRunnables<Cr>', 'rust-tools: runnables')
  nnoremap('<localleader>rt', '<cmd>lua _CARGO_TEST()<cr>', 'rust-tools: cargo test')
  nnoremap('<localleader>rm', '<cmd>RustExpandMacro<Cr>', 'rust-tools: expand cargo')
  nnoremap('<localleader>rc', '<cmd>RustOpenCargo<Cr>', 'rust-tools: open cargo')
  nnoremap('<localleader>rp', '<cmd>RustParentModule<Cr>', 'rust-tools: parent Module')
  nnoremap('<localleader>rd', '<cmd>RustDebuggables<Cr>', 'rust-tools: debuggables')
  nnoremap('<localleader>rv', '<cmd>RustViewCrateGraph<Cr>', 'rust-tools: view crate graph')
  nnoremap(
    '<localleader>rR',
    "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<Cr>",
    'rust-tools: reload workspace'
  )
  nnoremap('<localleader>ro', '<cmd>RustOpenExternalDocs<Cr>', 'rust-tools: open external docs')
end
