return {
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-lua/popup.nvim' },
  { 'kkharji/sqlite.lua', event = 'VeryLazy' },

  {
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff',
    init = function() rvim.nnoremap('<localleader>ll', '<cmd>Linediff<CR>', 'linediff: toggle') end,
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
    'LeonHeidelbach/trailblazer.nvim',
    event = 'VeryLazy',
    init = function()
      rvim.nnoremap('<leader>ms', '<cmd>TrailBlazerSaveSession<CR>', 'trailblazer: save session')
      rvim.nnoremap('<leader>ml', '<cmd>TrailBlazerLoadSession<CR>', 'trailblazer: load session')
    end,
    opts = {
      custom_session_storage_dir = join_paths(rvim.get_runtime_dir(), 'trailblazer'),
      trail_options = {
        current_trail_mark_list_type = 'quickfix',
      },
      mappings = {
        nv = {
          motions = {
            peek_move_next_down = '<A-K>',
            peek_move_previous_up = '<A-J>',
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
        borderchars = rvim.ui.border.common,
      })
      rvim.highlight.plugin('harpoon', {
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
    'numToStr/FTerm.nvim',
    event = 'VeryLazy',
    init = function()
      local function new_float(cmd)
        cmd =
          require('FTerm'):new({ cmd = cmd, dimensions = { height = 0.9, width = 0.9 } }):toggle()
      end
      local nnoremap, tnoremap = rvim.nnoremap, rvim.tnoremap
      nnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
      tnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
      nnoremap('<leader>lg', function() new_float('lazygit') end, 'fterm: toggle lazygit')
      nnoremap('<leader>ga', function() new_float('git add . ') end, 'add all')
      nnoremap('<leader>gc', function() new_float('git add . && git commit -a -v') end, 'commit')
      nnoremap('<leader>gD', function() new_float('iconf -ccma') end, 'commit dotfiles')
      nnoremap('<leader>tb', function() new_float('btop') end, 'fterm: btop')
      nnoremap('<leader>tn', function() new_float('node') end, 'fterm: node')
      nnoremap('<leader>tr', function() new_float('ranger') end, 'fterm: ranger')
      nnoremap('<leader>tp', function() new_float('python') end, 'fterm: python')
    end,
    opts = {
      border = rvim.ui.current.border,
      dimensions = { height = 0.8, width = 0.9 },
    },
  },

  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    init = function()
      rvim.nnoremap(
        '<leader>sr',
        '<cmd>lua require("persistence").load()<CR>',
        'persistence: restore for directory'
      )
      rvim.nnoremap(
        '<leader>sl',
        '<cmd>lua require("persistence").load({ last = true })<CR>',
        'persistence: restore last'
      )
    end,
    opts = {
      dir = vim.fn.expand(rvim.get_cache_dir() .. '/sessions/'),
      options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help' },
    },
  },

  {
    'ggandor/flit.nvim',
    keys = { 'n', 'f' },
    opts = {
      labeled_modes = 'nvo',
      multiline = false,
    },
  },

  {
    'mbbill/undotree',
    event = 'VeryLazy',
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth = 35
      rvim.nnoremap('<leader>u', '<cmd>UndotreeToggle<CR>', 'undotree: toggle')
    end,
  },

  {
    'iamcco/markdown-preview.nvim',
    build = function() vim.fn['mkdp#util#install']() end,
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
    'razak17/lab.nvim',
    event = 'InsertEnter',
    build = 'cd js && npm ci',
    opts = {
      runnerconf_path = join_paths(rvim.get_cache_dir(), 'lab', 'runnerconf'),
      code_runner = { enabled = false },
    },
  },

  {
    'razak17/package-info.nvim',
    event = 'BufRead package.json',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      autostart = false,
      package_manager = 'yarn',
    },
  },

  {
    'Saecki/crates.nvim',
    event = 'BufRead Cargo.toml',
    opts = {
      popup = {
        autofocus = true,
        style = 'minimal',
        border = rvim.ui.current.border,
        show_version_date = false,
        show_dependency_version = true,
        max_height = 30,
        min_width = 20,
        padding = 1,
      },
      null_ls = {
        enabled = true,
        name = 'crates.nvim',
      },
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
      { '<leader>rs', '<Plug>RestNvim', desc = 'rest: run' },
      { '<leader>rp', '<Plug>RestNvimPreview', desc = 'rest: preview' },
      { '<leader>rl', '<Plug>RestNvimLast', desc = 'rest: run last' },
    },
    opts = { skip_ssl_verification = true },
  },
}
