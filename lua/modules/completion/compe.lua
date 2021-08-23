return function()
  require("compe").setup {
    enabled = true,
    debug = false,
    min_length = 1,
    preselect = "always",
    documentation = {
      border = "single",
      winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
      max_width = 120,
      min_width = 60,
      max_height = math.floor(vim.o.lines * 0.3),
      min_height = 1,
    },
    source = {
      nvim_lsp = { kind = "   (LSP)" },
      vsnip = { kind = "   (Snippet)" },
      path = { kind = "   (Path)" },
      buffer = { kind = "   (Buffer)" },
      spell = { kind = "   (Spell)" },
      calc = { kind = "   (Calc)" },
      vim_dadbod_completion = true,
      emoji = { kind = " ﲃ  (Emoji)", filetypes = { "markdown", "text" } },
      tags = true,
      nvim_lua = false,
    },
  }
  -- Mappings
  local inoremap = rvim.inoremap
  local opts = { expr = true }
  inoremap("<C-Space>", "compe#complete()", opts)
  inoremap("<C-e>", "compe#close('<C-e>')", opts)
  inoremap("<C-f>", "compe#scroll({ 'delta': +4 })", opts)
  inoremap("<C-d>", "compe#scroll({ 'delta': -4 })", opts)
end
