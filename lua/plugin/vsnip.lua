local G = require "global"
local g =  vim.g
local mappings = require('utils.map')
local xmap, imap, smap, nnoremap = mappings.xmap, mappings.imap, mappings.smap, mappings.nnoremap
local npairs = require('nvim-autopairs')

_G.MUtils = {}

MUtils.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      vim.fn["compe#confirm"]()
      return npairs.esc("")
    else
      vim.fn.nvim_select_popupmenu_item(0, false, false,{})
      vim.fn["compe#confirm"]()
      return npairs.esc("<c-n>")
    end
  else
    return npairs.check_break_line_char()
  end
end

MUtils.tab=function()
  if vim.fn.pumvisible() ~= 0  then
    return npairs.esc("<C-n>")
  else
    if vim.fn["vsnip#available"](1) ~= 0 then
      vim.fn.feedkeys(string.format('%c%c%c(vsnip-expand-or-jump)', 0x80, 253, 83))
      return npairs.esc("")
    else
      return npairs.esc("<Tab>")
    end
  end
end

MUtils.s_tab=function()
  if vim.fn.pumvisible() ~= 0  then
    return npairs.esc("<C-p>")
  else
    if vim.fn["vsnip#jumpable"](-1) ~= 0 then
      vim.fn.feedkeys(string.format('%c%c%c(vsnip-jump-prev)', 0x80, 253, 83))
      return npairs.esc("")
    else
      return npairs.esc("<C-h>")
    end
  end
end

g["vsnip_snippet_dir"] = G.vim_path .. "snippets"

local opts = { expr = true }

xmap("<C-l>", "<Plug>(vsnip-select-text)")
xmap("<C-x>", "<Plug>(vsnip-cut-text)")

-- Autocompletion and snippets
imap("<CR>", "v:lua.MUtils.completion_confirm()", opts)
imap("<Tab>", "v:lua.MUtils.tab()", opts)
imap("<S-Tab>", "v:lua.MUtils.s_tab()", opts)

nnoremap('<Leader>cs', ':VsnipOpen<CR> 1<CR><CR>')
imap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", opts)
smap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", opts)
imap('<C-y>', "vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-space>'", opts)
smap('<C-y>', "vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-space>'", opts)
