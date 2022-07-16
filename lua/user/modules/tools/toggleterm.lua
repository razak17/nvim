return function()
  require('toggleterm').setup({
    open_mapping = [[<c-\>]],
    shade_filetypes = { 'none' },
    direction = 'float',
    insert_mappings = false,
    start_in_insert = true,
    winbar = {
      enabled = true,
    },
    highlights = {
      FloatBorder = { link = 'FloatBorder' },
      NormalFloat = { link = 'NormalFloat' },
    },
    float_opts = {
      border = rvim.style.border.current,
      winblend = 3,
    },
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
  })

  local float_handler = function(term)
    if vim.fn.mapcheck('jk', 't') ~= '' then
      vim.api.nvim_buf_del_keymap(term.bufnr, 't', 'jk')
      vim.api.nvim_buf_del_keymap(term.bufnr, 't', '<esc>')
    end
  end
  local Terminal = require('toggleterm.terminal').Terminal

  local function new_float(cmd, dir, hi)
    return Terminal:new({
      cmd = cmd,
      dir = dir ,
      hidden = true,
      direction = 'float',
      on_open = float_handler,
      highlights = hi and hi or {},
    })
  end

  local lazygit = new_float('lazygit', 'git_dir')
  local git_commit = new_float('git add . && git commit -v -a', 'git_dir')
  local conf_commit = new_float('iconf -ccma', '')
  local ranger = new_float('ranger', '')
  local node = new_float('node', '')
  local python = new_float('python', '')
  local btop = new_float('btop', '', {
    FloatBorder = { guibg = 'Black', guifg = 'DarkGray' },
    NormalFloat = { guibg = 'Black' },
  })

  rvim.command('Btop', function() btop:toggle() end)

  rvim.nnoremap('<leader>lg', function() lazygit:toggle() end, 'toggleterm: toggle lazygit')
  rvim.nnoremap('<leader>gc', function() git_commit:toggle() end, 'git: commit')
  rvim.nnoremap('<leader>gd', function() conf_commit:toggle() end, 'git: commit dotfiles')

  rvim.nnoremap('<leader>tb', function() btop:toggle() end, 'toggleterm: btop')
  rvim.nnoremap('<leader>tn', function() node:toggle() end, 'toggleterm: node')
  rvim.nnoremap('<leader>tr', function() ranger:toggle() end, 'toggleterm: ranger')
  rvim.nnoremap('<leader>tp', function() python:toggle() end, 'toggleterm: python')
end
