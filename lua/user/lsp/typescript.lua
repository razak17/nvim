if not rvim.plugin_installed('typescript.nvim') then return end

require('typescript').setup({
  disable_commands = false,
  debug = false,
  go_to_source_definition = {
    fallback = true,
  },
})
