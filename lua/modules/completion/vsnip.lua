return function()
  -- config
  vim.g.vsnip_snippet_dir = vim.g.vsnip_dir

  -- Mappings
  local xmap = rvim.xmap
  local imap = rvim.imap
  local smap = rvim.smap
  xmap("<C-x>", "<Plug>(vsnip-cut-text)")
  xmap("<C-l>", "<Plug>(vsnip-select-text)")
  rvim.nnoremap("<Leader>cs", ":VsnipOpen<CR> 1<CR><CR>")
  imap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", { expr = true })
  smap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", { expr = true })
end
