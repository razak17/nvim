if not rvim.plugin_installed('rust-tools.nvim') then return end

local dap = nil
local utils = require('user.utils')
local vscode_lldb = rvim.path.vscode_lldb
if utils.is_directory(vscode_lldb) then
  local codelldb_path = vscode_lldb .. '/adapter/codelldb'
  local liblldb_path = vscode_lldb .. '/lldb/lib/liblldb.so'
  dap = {
    adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
  }
end

require('rust-tools').setup({
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
  server = {
    -- setting it to false may improve startup time
    standalone = false,
    settings = {
      ['rust-analyzer'] = {
        lens = { enable = true },
        checkOnSave = { command = 'clippy' },
      },
    },
  },
})
