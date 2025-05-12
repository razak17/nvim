local fn, ui = vim.fn, ar.ui
local border = ui.current.border

return {
  {
    'akinsho/toggleterm.nvim',
    cond = not ar.plugin_disabled('toggleterm.nvim'),
    event = 'VeryLazy',
    opts = {
      open_mapping = [[<c-\>]],
      -- shade_filetypes = { 'none' },
      direction = 'float',
      autochdir = true,
      persist_mode = true,
      insert_mappings = false,
      start_in_insert = true,
      highlights = {
        FloatBorder = { link = 'FloatBorder' },
        NormalFloat = { link = 'NormalFloat' },
      },
      float_opts = {
        winblend = ar_config.ui.transparent.enable and 0 or 3,
        border = border,
      },
      size = function(term)
        if term.direction == 'horizontal' then return 15 end
        if term.direction == 'vertical' then
          return math.floor(vim.o.columns * 0.4)
        end
      end,
    },
    config = function(_, opts)
      require('toggleterm').setup(opts)

      local float_handler = function(term)
        vim.wo.sidescrolloff = 0
        if not ar.falsy(fn.mapcheck('jk', 't')) then
          vim.keymap.del('t', 'jk', { buffer = term.bufnr })
          vim.keymap.del('t', '<esc>', { buffer = term.bufnr })
        end
      end

      local Terminal = require('toggleterm.terminal').Terminal

      local lazygit = Terminal:new({
        cmd = 'lazygit',
        dir = 'git_dir',
        hidden = true,
        direction = 'float',
        on_open = float_handler,
      })

      map('n', '<leader>lg', function() lazygit:toggle() end, {
        desc = 'toggle lazygit',
      })
    end,
  },
  {
    'carldaws/surface.nvim',
    keys = {
      {
        '<localleader>o/',
        "<Cmd>lua require('surface').open(os.getenv('SHELL'), 'center')<CR>",
        desc = 'surface: open shell',
      },
    },
    opts = { default_position = 'right' },
  },
}
