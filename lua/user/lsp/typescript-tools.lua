local ok, tt = rvim.pcall(require, 'typescript-tools')

if not ok or rvim.find_string(rvim.plugins.disabled, 'typescript-tools.nvim') then return end

tt.setup({
  settings = {
    tsserver_file_preferences = {
      includeInlayParameterNameHints = 'literal',
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayVariableTypeHintsWhenTypeMatchesName = false,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = false,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
  },
})
