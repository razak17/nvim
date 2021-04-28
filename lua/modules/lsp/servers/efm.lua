if vim.fn.executable("efm-langserver") then
  require'modules.lsp.efm'.setup()
end

