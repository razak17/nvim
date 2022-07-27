return function()
  require('toggleterm').setup({
    open_mapping = [[<F2>]],
    shade_filetypes = { 'none' },
    shade_terminals = false,
    direction = 'float',
    insert_mappings = false,
    start_in_insert = true,
    highlights = {
      NormalFloat = { link = 'NormalFloat' },
      FloatBorder = { link = 'FloatBorder' },
    },
    float_opts = {
      width = 150,
      height = 30,
      winblend = 3,
      border = rvim.style.border.current,
    },
    size = function(term)
      if term.direction == 'horizontal' then return 10 end
      if term.direction == 'vertical' then return math.floor(vim.o.columns * 0.3) end
    end,
  })
  local Terminal = require('toggleterm.terminal').Terminal
  local new_term = function(direction, key, count)
    local fmt = string.format
    local cmd = fmt('<cmd>%sToggleTerm direction=%s<CR>', count, direction)
    return Terminal:new({
      direction = direction,
      on_open = function() vim.cmd('startinsert!') end,
      rvim.nnoremap(key, cmd),
      rvim.inoremap(key, cmd),
      rvim.tnoremap(key, cmd),
      count = count,
    })
  end
  local float_term = new_term('float', '<f2>', 1)
  local vertical_term = new_term('vertical', '<F3>', 2)
  local horizontal_term = new_term('horizontal', '<F4>', 3)
  rvim.nnoremap('<f2>', function() float_term:toggle() end)
  rvim.inoremap('<f2>', function() float_term:toggle() end)
  rvim.nnoremap('<F3>', function() vertical_term:toggle() end)
  rvim.inoremap('<F3>', function() vertical_term:toggle() end)
  rvim.nnoremap('<F4>', function() horizontal_term:toggle() end)
  rvim.inoremap('<F4>', function() horizontal_term:toggle() end)
end
