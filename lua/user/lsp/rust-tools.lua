if not rvim.plugin_installed('rust-tools.nvim') then return end

require('rust-tools').setup({
  tools = {
    runnables = { use_telescope = true },
    inlay_hints = {
      show_parameter_hints = false,
      parameter_hints_prefix = ' ',
    },
    hover_actions = { border = rvim.style.border.rectangle, auto_focus = true },
  },
  server = {
    -- setting it to false may improve startup time
    standalone = false,
    -- cmd = { 'rustup', 'run', 'nightly', rvim.path.mason .. '/bin/rust-analyzer' },
    settings = {
      ['rust-analyzer'] = {
        lens = { enable = true },
        checkOnSave = { command = 'clippy' },
      },
    },
  },
})

local nnoremap = rvim.nnoremap
local with_desc = function(desc) return { buffer = 0, desc = desc } end

nnoremap('<localleader>rh', '<cmd>RustToggleInlayHints<CR>', with_desc('rust-tools: toggle hints'))
nnoremap('<localleader>rr', '<cmd>RustRunnables<CR>', with_desc('rust-tools: runnables'))
nnoremap('<localleader>rt', '<cmd>lua _CARGO_TEST()<CR>', with_desc('rust-tools: cargo test'))
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
