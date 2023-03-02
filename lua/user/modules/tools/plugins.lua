local fn = vim.fn
local ui = rvim.ui

return {
  'nvim-lua/plenary.nvim',
  'nvim-lua/popup.nvim',
  'kkharji/sqlite.lua',

  {
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff',
    keys = {
      { '<localleader>ll', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
    },
  },

  {
    'ahmedkhalf/project.nvim',
    event = 'LspAttach',
    name = 'project_nvim',
    opts = {
      detection_methods = { 'pattern', 'lsp' },
      ignore_lsp = { 'null-ls' },
      patterns = { '.git' },
      datapath = rvim.get_runtime_dir(),
    },
  },

  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    opts = {
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept_word = '<M-w>',
          accept_line = '<M-l>',
          accept = '<M-u>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-\\>',
        },
      },
      filetypes = {
        gitcommit = false,
        NeogitCommitMessage = false,
        DressingInput = false,
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      },
      server_opts_overrides = {
        settings = {
          advanced = { inlineSuggestCount = 3 },
        },
      },
    },
  },

  {
    'LeonHeidelbach/trailblazer.nvim',
    keys = {
      '<M-l>',
      '<a-b>',
      '<a-j>',
      '<a-k>',
      { '<leader>ms', '<cmd>TrailBlazerSaveSession<CR>', desc = 'trailblazer: save session' },
      { '<leader>ml', '<cmd>TrailBlazerLoadSession<CR>', desc = 'trailblazer: load session' },
    },
    opts = {
      custom_session_storage_dir = join_paths(rvim.get_runtime_dir(), 'trailblazer'),
      trail_options = {
        current_trail_mark_list_type = 'quickfix',
      },
      mappings = {
        nv = {
          motions = {
            peek_move_next_down = '<a-j>',
            peek_move_previous_up = '<a-k>',
          },
        },
      },
    },
  },

  {
    'razak17/buffer_manager.nvim',
    keys = {
      {
        '<tab>',
        function() require('buffer_manager.ui').toggle_quick_menu() end,
        desc = 'buffer_manager: toggle',
      },
    },
    config = function()
      require('buffer_manager').setup({
        borderchars = ui.border.common,
      })
      rvim.highlight.plugin('buffer_manager', {
        theme = {
          ['zephyr'] = {
            { BufferManagerTitle = { fg = { from = 'Winbar' } } },
            { BufferManagerBorder = { fg = { from = 'FloatBorder' } } },
          },
        },
      })
    end,
  },

  {
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
      float_opts = {
        winblend = 3,
        border = ui.current.border,
      },
      size = function(term)
        if term.direction == 'horizontal' then return 15 end
        if term.direction == 'vertical' then return math.floor(vim.o.columns * 0.4) end
      end,
    },
    config = function(_, opts)
      require('toggleterm').setup(opts)

      local float_handler = function(term)
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
  },

  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    keys = {
      {
        '<leader>sr',
        '<cmd>lua require("persistence").load()<CR>',
        desc = 'persistence: restore for directory',
      },
      {
        '<leader>sl',
        '<cmd>lua require("persistence").load({ last = true })<CR>',
        desc = 'persistence: restore last',
      },
    },
    opts = {
      dir = fn.expand(rvim.get_cache_dir() .. '/sessions/'),
      options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help' },
    },
  },

  {
    'ggandor/flit.nvim',
    keys = { 'n', 'f' },
    opts = { labeled_modes = 'nvo', multiline = false },
  },

  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' },
    },
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth = 35
    end,
  },

  {
    'iamcco/markdown-preview.nvim',
    build = function() fn['mkdp#util#install']() end,
    ft = 'markdown',
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },

  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {
      preview = {
        border_chars = { '│', '│', '─', '─', '┌', '┐', '└', '┘', '▊' },
      },
    },
  },

  {
    'turbio/bracey.vim',
    ft = 'html',
    build = 'npm install --prefix server',
  },

  {
    'is0n/jaq-nvim',
    cmd = 'Jaq',
    keys = {
      { '<leader>rr', ':silent only | Jaq<CR>', desc = 'jaq: run' },
    },
    init = function()
      rvim.augroup('JaqConfig', {
        {
          event = { 'Filetype' },
          pattern = { 'Jaq' },
          command = function() vim.api.nvim_win_set_config(0, { border = rvim.ui.current.border }) end,
        },
      })
    end,
    opts = {
      cmds = {
        default = 'term',
        external = {
          typescript = 'ts-node %',
          javascript = 'node %',
          python = 'python %',
          rust = 'cargo run',
          cpp = 'g++ % -o $fileBase && ./$fileBase',
          go = 'go run %',
        },
      },
      behavior = { startinsert = true },
      terminal = { position = 'vert', size = 60 },
    },
  },

  {
    'razak17/lab.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>rl', ':Lab code run<CR>', desc = 'lab: run' },
      { '<leader>rx', ':Lab code stop<CR>', desc = 'lab: stop' },
      { '<leader>rp', ':Lab code panel<CR>', desc = 'lab: panel' },
    },
    build = 'cd js && npm ci',
    opts = { runnerconf_path = join_paths(rvim.get_runtime_dir(), 'lab', 'runnerconf') },
  },

  {
    'razak17/package-info.nvim',
    event = 'BufRead package.json',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = { autostart = false, package_manager = 'yarn' },
  },

  {
    'Saecki/crates.nvim',
    event = 'BufRead Cargo.toml',
    opts = {
      popup = {
        autofocus = true,
        style = 'minimal',
        border = ui.current.border,
        show_version_date = false,
        show_dependency_version = true,
        max_height = 30,
        min_width = 20,
        padding = 1,
      },
      null_ls = { enabled = true, name = 'crates.nvim' },
    },
  },

  {
    'shortcuts/no-neck-pain.nvim',
    keys = {
      {
        '<leader>on',
        function() require('no-neck-pain').toggle() end,
        mode = 'n',
        desc = 'toggle no-neck-pain',
        noremap = true,
        silent = true,
        expr = false,
      },
    },
  },

  {
    'NTBBloodbath/rest.nvim',
    ft = { 'http', 'json' },
    keys = {
      { '<localleader>rs', '<Plug>RestNvim', desc = 'rest: run' },
      { '<localleader>rp', '<Plug>RestNvimPreview', desc = 'rest: preview' },
      { '<localleader>rl', '<Plug>RestNvimLast', desc = 'rest: run last' },
    },
    opts = { skip_ssl_verification = true },
  },
}
