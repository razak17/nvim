local npairs = require('nvim-autopairs')

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function check_back_space()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

_G.completion_confirm = function()
  if vim.fn.pumvisible() == 1 then
    if vim.fn.complete_info()["selected"] ~= -1 then
      vim.fn["compe#confirm"]()
      return npairs.esc("<c-y>")
    else
      vim.fn.nvim_select_popupmenu_item(0, false, false, {})
      vim.fn["compe#confirm"]()
      return npairs.esc("<c-n><c-y>")
    end
  else
    return npairs.check_break_line_char()
  end
end

_G.tab = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end

_G.s_tab = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<S-Tab>"
  end
end

_G.enhance_jk_move = function(key)
  if not packer_plugins['accelerated-jk'].loaded then
    vim.cmd [[packadd accelerated-jk]]
  end
  local map = key == 'n' and '<Plug>(accelerated_jk_j)' or
                  '<Plug>(accelerated_jk_gk)'
  return t(map)
end

_G.enhance_ft_move = function(key)
  if not packer_plugins['vim-eft'].loaded then
    vim.cmd [[packadd vim-eft]]
  end
  local map = {
    f = '<Plug>(eft-f)',
    F = '<Plug>(eft-F)',
    [';'] = '<Plug>(eft-repeat)'
  }
  return t(map[key])
end

