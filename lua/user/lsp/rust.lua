local status_ok, rust_tools = rvim.safe_require('rust-tools')
if not status_ok then
  print('Failed to load rust-tools')
  return
end
local dap = nil
local utils = require('user.utils')
local vscode_lldb = rvim.paths.vscode_lldb
local get_config = require('user.core.servers')
if utils.is_directory(vscode_lldb) then
  local codelldb_path = vscode_lldb .. '/adapter/codelldb'
  local liblldb_path = vscode_lldb .. '/lldb/lib/liblldb.so'
  dap = {
    adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
  }
end
local server = {
  -- setting it to false may improve startup time
  -- standalone = false,
  cmd = { 'rustup', 'run', 'nightly', rvim.paths.mason .. '/bin/rust-analyzer' },
  settings = {
    ['rust-analyzer'] = {
      lens = {
        enable = true,
      },
      checkOnSave = {
        command = 'clippy',
      },
    },
  },
}

rust_tools.setup({
  tools = {
    runnables = { use_telescope = true },
    inlay_hints = {
      only_current_line = false,
      only_current_line_autocmd = 'CursorHold',
      show_parameter_hints = false,
      show_variable_name = false,
      parameter_hints_prefix = ' ',
      max_len_align = false,
      max_len_align_padding = 1,
      right_align = false,
      right_align_padding = 7,
      highlight = 'Comment',
    },
    hover_actions = { border = rvim.style.border.rectangle, auto_focus = true },
  },
  dap = dap,
  -- all the opts to send to nvim-lspconfig
  -- these override the defaults set by rust-tools.nvim
  server = vim.tbl_deep_extend('force', get_config('rust_analyzer'), server),
})
