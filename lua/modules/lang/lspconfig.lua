return function()
  for _, server in ipairs(rvim.lsp.servers) do
    require("lsp.manager").setup(server)
  end

  require("lsp").setup()
end
