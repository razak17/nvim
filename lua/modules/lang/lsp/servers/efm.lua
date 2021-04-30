if vim.fn.executable("efm-langserver") then
  require'modules.lang.lsp.efm'.setup()
end

