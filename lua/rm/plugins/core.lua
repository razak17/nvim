local cmd, fn = vim.cmd, vim.fn
local border = rvim.ui.current.border

return {
  ------------------------------------------------------------------------------
  -- Core {{{3
  ------------------------------------------------------------------------------
  'nvim-lua/plenary.nvim',
  'nvim-tree/nvim-web-devicons',
  'b0o/schemastore.nvim',
  -- { 'lewis6991/fileline.nvim', lazy = false },
  -- { 'axlebedev/vim-footprints', lazy = false },
  {
    'romainl/vim-cool',
    cond = false,
    event = 'BufReadPre',
    config = function() vim.g.CoolTotalMatches = 1 end,
  },
  {
    'olimorris/persisted.nvim',
    cond = not rvim.plugins.minimal and rvim.treesitter.enable,
    lazy = false,
    init = function() rvim.command('ListSessions', 'Telescope persisted') end,
    opts = {
      use_git_branch = true,
      save_dir = fn.expand(vim.fn.stdpath('cache') .. '/sessions/'),
      ignored_dirs = { vim.fn.stdpath('data') },
      on_autoload_no_session = function() cmd.Alpha() end,
      should_autosave = function()
        return vim.bo.filetype ~= 'alpha' and vim.bo.filetype ~= 'markdown'
      end,
    },
  },
  {
    'mrjones2014/smart-splits.nvim',
    opts = {},
    build = './kitty/install-kittens.bash',
  },
  {
    'razak17/lspkind.nvim',
    config = function() require('lspkind').init({ preset = 'codicons' }) end,
  },
  {
    'axieax/urlview.nvim',
    cmd = { 'UrlView' },
    keys = {
      { '<leader>ub', '<cmd>UrlView buffer<cr>', desc = 'urlview: buffers' },
      { '<leader>ul', '<cmd>UrlView lazy<cr>', desc = 'urlview: lazy' },
      {
        '<leader>uc',
        '<cmd>UrlView buffer action=clipboard<cr>',
        desc = 'urlview: copy links',
      },
    },
    opts = {
      default_title = 'Links:',
      default_picker = 'native',
      default_prefix = 'https://',
      default_action = 'system',
    },
  },
  {
    'neuromaancer/readup.nvim',
    cmd = { 'Readup', 'ReadupBrowser' },
    opts = { float = true },
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Editing {{{1
  ------------------------------------------------------------------------------
  {
    'assistcontrol/readline.nvim',
    -- stylua: ignore
    keys = {
      { '<M-f>', function() require('readline').forward_word() end, mode = '!' },
      { '<M-b>', function() require('readline').backward_word() end, mode = '!' },
      { '<C-a>', function() require('readline').beginning_of_line() end, mode = '!' },
      { '<C-e>', function() require('readline').end_of_line() end, mode = '!' },
      { '<M-d>', function() require('readline').kill_word() end, mode = '!' },
      { '<M-BS>', function() require('readline').backward_kill_word() end, mode = '!' },
      { '<C-w>', function() require('readline').unix_word_rubout() end, mode = '!' },
      { '<C-k>', function() require('readline').kill_line() end, mode = '!' },
      { '<C-u>', function() require('readline').backward_kill_line() end, mode = '!' },
    },
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Utilities {{{1
  ------------------------------------------------------------------------------
  { 'sQVe/sort.nvim', cmd = { 'Sort' } },
  { 'lambdalisue/suda.vim', lazy = false },
  { 'will133/vim-dirdiff', cmd = { 'DirDiff' } },
  { 'godlygeek/tabular', cmd = { 'Tabularize' } },
  { 'sammce/fleeting.nvim', lazy = false },
  { 'mrquantumcodes/configpulse', lazy = false },
  { 'ton/vim-bufsurf', lazy = false },
  {
    'CodingdAwn/vim-choosewin',
    keys = { { '<leader>ow', '<Plug>(choosewin)', desc = 'choose window' } },
    config = function() vim.g.choosewin_overlay_enable = 1 end,
  },
  {
    'kevinhwang91/nvim-fundo',
    event = { 'BufRead', 'BufNewFile' },
    build = function() require('fundo').install() end,
    dependencies = { 'kevinhwang91/promise-async' },
  },
  {
    'smoka7/multicursors.nvim',
    cond = not rvim.plugins.minimal and rvim.treesitter.enable,
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'smoka7/hydra.nvim' },
    opts = {
      hint_config = { border = border },
    },
    cmd = {
      'MCstart',
      'MCvisual',
      'MCclear',
      'MCpattern',
      'MCvisualPattern',
      'MCunderCursor',
    },
    keys = {
      {
        '<M-e>',
        '<cmd>MCstart<cr>',
        mode = { 'v', 'n' },
        desc = 'Create a selection for selected text or word under the cursor',
      },
    },
  },
  {
    'folke/flash.nvim',
    opts = {
      modes = {
        char = {
          keys = { 'f', 'F', 't', 'T', ';' }, -- remove "," from keys
        },
        search = { enabled = false },
      },
      jump = { nohlsearch = true },
    },
    -- stylua: ignore
    keys = {
      { 's', function() require('flash').jump() end, mode = { 'n', 'x', 'o' } },
      { 'S', function() require('flash').treesitter() end, mode = { 'o', 'x' }, },
      { 'r', function() require('flash').remote() end, mode = 'o', desc = 'Remote Flash', },
      { '<c-s>', function() require('flash').toggle() end, mode = { 'c' }, desc = 'Toggle Flash Search', },
      { 'R', function() require('flash').treesitter_search() end, mode = { 'o', 'x' }, desc = 'Flash Treesitter Search', },
    },
  },
  {
    'kungfusheep/randomword.nvim',
    event = 'VeryLazy',
    config = function()
      local js = {
        default = 'console.log("<word>", <cursor>)',
        line = 'console.log("<word>")',
      }
      require('randomword').setup({
        templates = {
          lua = {
            default = 'print(string.format("<word> %s", <cursor>))',
            line = "print('<word>')",
          },
          go = {
            default = 'fmt.Printf("<word>: %v \\n", <cursor>)',
            line = 'fmt.Println("<word>")',
          },
          python = {
            default = 'print(string.format("<word> %s", <cursor>))',
            line = "print('<word>')",
          },
          javascript = js,
          javascriptreact = js,
          typescript = js,
          typescriptreact = js,
        },
        keybinds = {
          default = '<leader>pd',
          line = '<leader>pl',
        },
      })
    end,
  },
  {
    'andrewferrier/debugprint.nvim',
    cond = rvim.treesitter.enable,
    keys = {
      {
        '<leader>pp',
        function() return require('debugprint').debugprint({ variable = true }) end,
        expr = true,
        desc = 'debugprint: cursor',
      },
      {
        '<leader>pP',
        function()
          return require('debugprint').debugprint({
            above = true,
            variable = true,
          })
        end,
        expr = true,
        desc = 'debugprint: cursor (above)',
      },
      {
        '<leader>pi',
        function()
          return require('debugprint').debugprint({
            ignore_treesitter = true,
            variable = true,
          })
        end,
        expr = true,
        desc = 'debugprint: prompt',
      },
      {
        '<leader>pI',
        function()
          return require('debugprint').debugprint({
            ignore_treesitter = true,
            above = true,
            variable = true,
          })
        end,
        expr = true,
        desc = 'debugprint:prompt (above)',
      },
      {
        '<leader>po',
        function() return require('debugprint').debugprint({ motion = true }) end,
        expr = true,
        desc = 'debugprint: operator',
      },
      {
        '<leader>pO',
        function()
          return require('debugprint').debugprint({
            above = true,
            motion = true,
          })
        end,
        expr = true,
        desc = 'debugprint: operator (above)',
      },
      {
        '<leader>px',
        '<Cmd>DeleteDebugPrints<CR>',
        desc = 'debugprint: clear all',
      },
    },
    opts = { create_keymaps = false },
    config = function(opts)
      require('debugprint').setup(opts)

      local svelte = {
        left = 'console.log("',
        right = '")',
        mid_var = '", ',
        right_var = ')',
      }
      local python = {
        left = 'print(f"',
        right = '"',
        mid_var = '{',
        right_var = '}")',
      }
      local js = {
        left = 'console.log("',
        right = '")',
        mid_var = '", ',
        right_var = ')',
      }
      require('debugprint').add_custom_filetypes({
        python = python,
        svelte = svelte,
        javascript = js,
        javascriptreact = js,
        typescript = js,
        typescriptreact = js,
        tsx = js,
      })
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff',
    keys = {
      { '<localleader>lL', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
    },
  },
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>U', '<cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' },
    },
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth = 35
    end,
  },
  {
    'ahmedkhalf/project.nvim',
    cond = not rvim.plugins.minimal,
    event = 'VimEnter',
    name = 'project_nvim',
    opts = {
      detection_methods = { 'pattern', 'lsp' },
      ignore_lsp = { 'null-ls' },
      patterns = { '.git' },
    },
  },
  {
    'chrisgrieser/nvim-genghis',
    cond = not rvim.plugins.minimal,
    commit = 'b045df8264e549434a4e1dd5a27d09893f12695e',
    dependencies = 'stevearc/dressing.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    -- stylua: ignore
    config = function()
      local g = require('genghis')
      map('n', '<localleader>fp', g.copyFilepath, { desc = 'genghis: yank filepath' })
      map('n', '<localleader>fn', g.copyFilename, { desc = 'genghis: yank filename' })
      map('n', '<localleader>fr', g.renameFile, { desc = 'genghis: rename file' })
      map('n', '<localleader>fm', g.moveAndRenameFile, { desc = 'genghis: move and rename' })
      map('n', '<localleader>fc', g.createNewFile, { desc = 'genghis: create new file' })
      map('n', '<localleader>fd', g.duplicateFile, { desc = 'genghis: duplicate current file' })
    end,
  },
  {
    'AckslD/muren.nvim',
    cmd = { 'MurenToggle', 'MurenUnique', 'MurenFresh' },
    opts = {},
  },
  {
    'jpalardy/vim-slime',
    cond = rvim.plugins.niceties,
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      { '<localleader>St', '<Plug>SlimeParagraphSend', desc = 'slime: paragraph', },
      { '<localleader>St', '<Plug>SlimeRegionSend', mode = { 'x' }, desc = 'slime: region', },
      { '<localleader>Sc', '<Plug>SlimeConfig', desc = 'slime: config' },
    },
    config = function()
      vim.g.slime_target = 'tmux'
      vim.g.slime_paste_file = vim.fn.stdpath('data') .. '/.slime_paste'
      vim.g.alime_no_mappings = 1
    end,
  },
  {
    'luckasRanarison/nvim-devdocs',
    cond = not rvim.plugins.minimal,
    -- stylua: ignore
    keys = {
      { '<localleader>vf', '<cmd>DevdocsOpenFloat<CR>', desc = 'devdocs: open float', },
      { '<localleader>vb', '<cmd>DevdocsOpen<CR>', desc = 'devdocs: open in buffer', },
      { '<localleader>vo', '<cmd>DevdocsOpenFloat ', desc = 'devdocs: open documentation', },
      { '<localleader>vi', '<cmd>DevdocsInstall ', desc = 'devdocs: install' },
      { '<localleader>vu', '<cmd>DevdocsUninstall ', desc = 'devdocs: uninstall' },
    },
    opts = {
      -- stylua: ignore
      ensure_installed = {
        'git', 'bash', 'lua-5.4', 'html', 'css', 'javascript', 'typescript',
        'react', 'svelte', 'web_extensions', 'postgresql-15', 'python-3.11',
        'go', 'docker', 'tailwindcss', 'astro',
      },
      wrap = true,
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    '2kabhishek/nerdy.nvim',
    cmd = 'Nerdy',
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-telescope/telescope.nvim',
    },
  },
  {
    'ragnarok22/whereami.nvim',
    cmd = 'Whereami',
  },
  {
    'willothy/flatten.nvim',
    lazy = false,
    cond = false,
    priority = 1001,
    opts = {
      window = { open = 'tab' },
      block_for = {
        gitcommit = true,
        gitrebase = true,
      },
      post_open = function(bufnr, winnr, _, is_blocking)
        vim.w[winnr].is_remote = true
        if is_blocking then
          vim.bo.bufhidden = 'wipe'
          vim.api.nvim_create_autocmd('BufHidden', {
            desc = 'Close window when buffer is hidden',
            callback = function()
              if vim.api.nvim_win_is_valid(winnr) then
                vim.api.nvim_win_close(winnr, true)
              end
            end,
            buffer = bufnr,
            once = true,
          })
        end
      end,
    },
  },
  {
    'bgaillard/readonly.nvim',
    cond = not rvim.plugins.minimal and rvim.plugins.niceties,
    lazy = false,
    opts = {
      secured_files = {
        '~/%.aws/config',
        '~/%.aws/credentials',
        '~/%.ssh/.',
        '~/%.secrets.yaml',
        '~/%.vault-crypt-files/.',
      },
    },
    dependencies = { 'rcarriga/nvim-notify' },
  },
  -- Games
  --------------------------------------------------------------------------------
  { 'ThePrimeagen/vim-be-good', cmd = 'VimBeGood' },
  { 'NStefan002/speedtyper.nvim', cmd = 'Speedtyper', opts = {} },
  {
    'Febri-i/snake.nvim',
    opts = {},
    cmd = { 'SnakeStart' },
    dependencies = { 'Febri-i/fscreen.nvim' },
  },
  {
    'NStefan002/2048.nvim',
    cmd = 'Play2048',
    opts = {},
  },
  {
    'NStefan002/15puzzle.nvim',
    cmd = 'Play15puzzle',
    opts = {},
  },
  -- Share Code
  --------------------------------------------------------------------------------
  { 'TobinPalmer/rayso.nvim', cmd = { 'Rayso' }, opts = {} },
  { 'ellisonleao/carbon-now.nvim', cmd = 'CarbonNow', opts = {} },
  { 'Sanix-Darker/snips.nvim', cmd = { 'SnipsCreate' }, opts = {} },
  -- }}}
}
