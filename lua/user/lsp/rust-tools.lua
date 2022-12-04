if not rvim.plugin_loaded('rust-tools.nvim') then return end

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
