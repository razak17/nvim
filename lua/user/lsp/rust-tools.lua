if not rvim.plugin_loaded('rust-tools.nvim') then return end

require('rust-tools').setup({
  tools = {
    runnables = { use_telescope = false },
    inlay_hints = {
      show_parameter_hints = false,
      parameter_hints_prefix = ' ',
    },
    hover_actions = { border = rvim.style.border.rectangle, auto_focus = true },
  },
  dap = {
    adapter = require('rust-tools.dap').get_codelldb_adapter(
      rvim.path.codelldb .. '/adapter/codelldb',
      rvim.path.codelldb .. '/lldb/lib/liblldb.so'
    ),
  },
  server = {
    -- cmd = { 'rustup', 'run', 'nightly', rvim.path.mason .. '/bin/rust-analyzer' },
    settings = {
      ['rust-analyzer'] = {
        lens = { enable = true },
        checkOnSave = { command = 'clippy' },
      },
    },
  },
})
