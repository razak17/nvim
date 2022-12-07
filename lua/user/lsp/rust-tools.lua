if not rvim.plugin_loaded('rust-tools.nvim') then return end

local ok, which_key = rvim.safe_require('which-key')
if ok then which_key.register({ ['<localleader>'] = { r = { name = 'Rust Tools' } } }) end

require('rust-tools').setup({
  tools = {
    runnables = { use_telescope = false },
    inlay_hints = {
      show_parameter_hints = false,
      parameter_hints_prefix = ' ',
    },
    hover_actions = {
      border = rvim.style.border.rectangle,
      auto_focus = true,
      max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
      max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
    },
  },
  dap = {
    adapter = require('rust-tools.dap').get_codelldb_adapter(
      rvim.path.codelldb .. '/adapter/codelldb',
      rvim.path.codelldb .. '/lldb/lib/liblldb.so'
    ),
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
