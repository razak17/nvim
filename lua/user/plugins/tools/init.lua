local fn, ui, hl = vim.fn, rvim.ui, rvim.highlight
local border = ui.current.border

return {
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
    -- stylua: ignore
    keys = {
      '<M-l>', '<a-b>', '<a-j>', '<a-k>',
      { '<leader>ms', '<cmd>TrailBlazerSaveSession<CR>', desc = 'trailblazer: save session' },
      { '<leader>ml', '<cmd>TrailBlazerLoadSession<CR>', desc = 'trailblazer: load session' },
    },
    opts = {
      custom_session_storage_dir = join_paths(rvim.get_runtime_dir(), 'trailblazer'),
      trail_options = {
        current_trail_mark_list_type = 'quickfix',
      },
      mappings = {
        nv = { motions = { peek_move_next_down = '<a-j>', peek_move_previous_up = '<a-k>' } },
      },
    },
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
  },
  { 'turbio/bracey.vim', ft = 'html', build = 'npm install --prefix server' },
  {
    'razak17/lab.nvim',
    event = 'InsertEnter',
    keys = {
      { '<leader>rl', ':Lab code run<CR>', desc = 'lab: run' },
      { '<leader>rx', ':Lab code stop<CR>', desc = 'lab: stop' },
      { '<leader>rp', ':Lab code panel<CR>', desc = 'lab: panel' },
    },
    build = 'cd js && npm ci',
    config = function()
      hl.plugin('lab', {
        theme = {
          ['zephyr'] = {
            {
              DiagnosticVirtualTextHint = {
                bg = { from = 'CursorLine' },
                fg = { from = 'Winbar' },
              },
            },
          },
        },
      })
      require('lab').setup({
        runnerconf_path = join_paths(rvim.get_runtime_dir(), 'lab', 'runnerconf'),
      })
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
        border = border,
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
