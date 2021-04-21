if vim.fn.executable("efm-langserver") then
  local enhance_attach = require'modules.lsp.servers'.enhance_attach
  require'modules.lsp.efm'.setup(enhance_attach)
end

