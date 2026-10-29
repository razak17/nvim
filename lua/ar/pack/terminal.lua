local border = ar.ui.current.border.default

local function get_cond(plugin, variant)
  local condition = ar.config.terminal.enable
    and ar.config.terminal.variant == variant
  return ar.get_plugin_cond(plugin, condition)
end

ar.pack.add({
  {
    src = 'https://github.com/nvzone/floaterm',
    cmd = { 'FloatermToggle' },
    cond = get_cond('floaterm', 'floaterm'),
    setup = function()
      require('floaterm').setup({
        mappings = {
          term = function(buf)
            local function float(dir)
              return function() require('floaterm.api').cycle_term_bufs(dir) end
            end
            map({ 'n', 't' }, '<C-p>', float('prev'), { buffer = buf })
            map({ 'n', 't' }, '<C-n>', float('next'), { buffer = buf })
          end,
        },
      })
    end,
    keys = function(load)
      map({ 'n', 't' }, '<C-\\>', function()
        load()
        vim.cmd('FloatermToggle')
      end, { desc = 'floaterm: toggle terminal' })
    end,
    dependencies = {
      { src = 'https://github.com/nvzone/volt' },
    },
  },
  {
    src = 'https://github.com/ruicsh/termite.nvim',
    cond = get_cond('termite.nvim', 'termite'),
    event = 'VeryLazy',
    cmd = { 'Termite' },
    setup = function()
      require('termite').setup({
        width = 0.4, -- Fraction of editor width for left/right positions (0.0 - 1.0)
        height = 0.5, -- Fraction of editor height for top/bottom positions (0.0 - 1.0)
        position = 'right', -- Panel position: "left", "right", "top", or "bottom"
        shell = nil, -- Shell command (nil = default $SHELL)
        start_insert = true, -- Enter insert mode when focusing a terminal
        winbar = false, -- Show winbar with running process or cwd
        keymaps = {
          toggle = '<C-\\>', -- Toggle all terminals (terminal mode)
          create = '<C-t>', -- Create new terminal
          next = '<C-n>', -- Focus next terminal in stack
          prev = '<C-p>', -- Focus previous terminal in stack
          focus_editor = '<C-e>', -- Return focus to editor window
          normal_mode = '<C-[>', -- Exit terminal insert mode
          maximize = '<C-z>', -- Maximize/restore focused terminal
          close = 'q', -- Close current terminal (normal mode)
        },
        highlights = {
          border_active = 'Debug', -- Highlight for active terminal border (string = hl group, table = direct definition)
          border_inactive = 'WinSeparator', -- Highlight for inactive terminal borders (string = hl group, table = direct definition)
        },
        wo = { signcolumn = 'no' },
      })
    end,
  },
  {
    src = 'https://github.com/akinsho/toggleterm.nvim',
    cond = get_cond('toggleterm.nvim', 'toggleterm'),
    event = 'VeryLazy',
    setup = function()
      require('toggleterm').setup({
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
          winblend = ar.config.ui.transparent.enable and 0 or 3,
          border = border,
        },
        size = function(term)
          if term.direction == 'horizontal' then return 15 end
          if term.direction == 'vertical' then
            return math.floor(vim.o.columns * 0.4)
          end
        end,
      })

      local float_handler = function(term)
        vim.wo.sidescrolloff = 0
        if not ar.falsy(vim.fn.mapcheck('jk', 't')) then
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

      map('n', '<leader>gg', function() lazygit:toggle() end, {
        desc = 'toggle lazygit',
      })
    end,
  },
  {
    src = 'https://github.com/carldaws/surface.nvim',
    cond = ar.get_plugin_cond('surface.nvim'),
    keys = function(load)
      map('n', '<localleader>o/', function()
        load()
        require('surface').open(vim.env.SHELL, 'center')
      end, { desc = 'surface: open shell' })
    end,
    setup = function() require('surface').setup({ default_position = 'right' }) end,
  },
})
