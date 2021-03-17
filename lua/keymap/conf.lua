local npairs = require('nvim-autopairs')

_G.completion_confirm=function()
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

_G.tab=function()
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

_G.s_tab=function()
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

