local fn, ui = vim.fn, ar.ui
local border = ui.current.border.default

local function get_cond(plugin, variant)
  local condition = ar.config.terminal.enable
    and ar.config.terminal.variant == variant
  return ar.get_plugin_cond(plugin, condition)
end

-- Native pack startup has no lazy.nvim VeryLazy event.
local function after_startup(load)
  if vim.v.vim_did_enter == 1 then
    vim.schedule(load)
  else
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = function() vim.schedule(load) end,
    })
  end
end

if get_cond('floaterm', 'floaterm') then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add({
      'https://github.com/nvzone/volt',
      'https://github.com/nvzone/floaterm',
    }, { confirm = false })
    local opts = {
      mappings = {
        term = function(buf)
          local function float(dir)
            return function() require('floaterm.api').cycle_term_bufs(dir) end
          end
          map({ 'n', 't' }, '<C-p>', float('prev'), { buffer = buf })
          map({ 'n', 't' }, '<C-n>', float('next'), { buffer = buf })
        end,
      },
    }
    require('floaterm').setup(opts)
    loaded = true
  end
  ar.pack.cmd('FloatermToggle', load)
  map({ 'n', 't' }, '<C-\\>', function()
    load()
    vim.cmd('FloatermToggle')
  end, { desc = 'floaterm: toggle terminal' })
end

if get_cond('termite.nvim', 'termite') then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add({
      'https://github.com/ruicsh/termite.nvim',
    }, { confirm = false })
    local opts = {
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
    }
    require('termite').setup(opts)
    loaded = true
  end
  ar.pack.cmd({ 'Termite' }, load)
  after_startup(load)
end

if get_cond('toggleterm.nvim', 'toggleterm') then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add({
      'https://github.com/akinsho/toggleterm.nvim',
    }, { confirm = false })
    local opts = {
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
    }
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

    map('n', '<leader>gg', function() lazygit:toggle() end, {
      desc = 'toggle lazygit',
    })
    loaded = true
  end
  after_startup(load)
end

if ar.get_plugin_cond('surface.nvim') then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add({
      'https://github.com/carldaws/surface.nvim',
    }, { confirm = false })
    local opts = { default_position = 'right' }
    require('surface').setup(opts)
    loaded = true
  end
  map('n', '<localleader>o/', function()
    load()
    require('surface').open(vim.env.SHELL, 'center')
  end, { desc = 'surface: open shell' })
end
