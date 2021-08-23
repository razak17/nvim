return function()
  local fn = vim.fn
  local t = rvim.t

  local function check_back_space()
    local col = fn.col "." - 1
    if col == 0 or fn.getline("."):sub(col, col):match "%s" then
      return true
    else
      return false
    end
  end

  function _G.tab_complete()
    if fn.pumvisible() == 1 then
      return t "<C-n>"
    elseif vim.fn.call("vsnip#jumpable", { 1 }) == 1 then
      return t "<Plug>(vsnip-jump-next)"
    elseif fn.call("vsnip#available", { 1 }) == 1 then
      return t "<Plug>(vsnip-expand-or-jump)"
    elseif check_back_space() then
      return t "<Tab>"
    else
      return fn["compe#complete"]()
    end
  end

  function _G.s_tab_complete()
    if fn.pumvisible() == 1 then
      return t "<C-p>"
    elseif fn.call("vsnip#jumpable", { -1 }) == 1 then
      return t "<Plug>(vsnip-jump-prev)"
    else
      return t "<S-Tab>"
    end
  end

  -- config
  vim.g.vsnip_snippet_dir = vim.g.vsnip_dir

  -- Mappings
  local imap = rvim.imap
  local smap = rvim.smap
  local xmap = rvim.xmap
  local nnoremap = rvim.nnoremap
  local opts = { expr = true }
  xmap("<C-x>", "<Plug>(vsnip-cut-text)")
  xmap("<C-l>", "<Plug>(vsnip-select-text)")
  imap("<Tab>", "v:lua.tab_complete()", opts)
  smap("<Tab>", "v:lua.tab_complete()", opts)
  imap("<S-Tab>", "v:lua.s_tab_complete()", opts)
  smap("<S-Tab>", "v:lua.s_tab_complete()", opts)
  nnoremap("<Leader>cs", ":VsnipOpen<CR> 1<CR><CR>")
  imap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", opts)
  smap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", opts)
end
