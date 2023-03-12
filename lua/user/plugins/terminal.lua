local fn, ui = vim.fn, rvim.ui
local border = ui.current.border

return {
  'akinsho/toggleterm.nvim',
  event = 'VeryLazy',
  opts = {
    open_mapping = [[<c-\>]],
    shade_filetypes = { 'none' },
    direction = 'float',
    autochdir = true,
    persist_mode = true,
    insert_mappings = false,
    start_in_insert = true,
    winbar = { enabled = ui.winbar.enable },
    highlights = {
      FloatBorder = { link = 'FloatBorder' },
      NormalFloat = { link = 'NormalFloat' },
    },
    float_opts = { winblend = 3, border = border },
    size = function(term)
      if term.direction == 'horizontal' then return 15 end
      if term.direction == 'vertical' then return math.floor(vim.o.columns * 0.4) end
    end,
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    local float_handler = function(term)
      vim.wo.sidescrolloff = 0
      if not rvim.empty(fn.mapcheck('jk', 't')) then
        vim.keymap.del('t', 'jk', { buffer = term.bufnr })
        vim.keymap.del('t', '<esc>', { buffer = term.bufnr })
      end
    end

    local Terminal = require('toggleterm.terminal').Terminal

    local function git_float(cmd)
      return Terminal:new({
        cmd = cmd,
        dir = 'git_dir',
        hidden = true,
        direction = 'float',
        on_open = float_handler,
      }):toggle()
    end

    local function lazygit() git_float('lazygit') end
    local function git_add() git_float('git add .') end
    local function git_commit() git_float('git add . && git commit -a -v') end
    local function dotfiles() git_float('iconf -ccma') end

    map('n', '<leader>lg', lazygit, { desc = 'toggleterm: lazygit' })
    map('n', '<leader>ga', git_add, { desc = 'toggleterm: add all' })
    map('n', '<leader>gc', git_commit, { desc = 'toggleterm: commit' })
    map('n', '<leader>gD', dotfiles, { desc = 'toggleterm: commit dotfiles' })
  end,
}
