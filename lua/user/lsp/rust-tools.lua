if not rvim.plugin_loaded('rust-tools.nvim') then return end

local codelldb_path = rvim.path.vscode_lldb .. '/adapter/codelldb'
local liblldb_path = rvim.path.vscode_lldb .. '/lldb/lib/liblldb.so'

require('rust-tools').setup({
  tools = {
    runnables = { use_telescope = true },
    inlay_hints = {
      show_parameter_hints = false,
      parameter_hints_prefix = ' ',
    },
    hover_actions = { border = rvim.style.border.rectangle, auto_focus = true },
  },
  dap = {
    adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
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
