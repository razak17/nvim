local cmd, fn = vim.cmd, vim.fn
local border = rvim.ui.current.border
local minimal, niceties = rvim.plugins.minimal, rvim.plugins.niceties

return {
  ------------------------------------------------------------------------------
  -- Core {{{1
  ------------------------------------------------------------------------------
  'nvim-lua/plenary.nvim',
  'MunifTanjim/nui.nvim',
  'nvim-tree/nvim-web-devicons',
  'b0o/schemastore.nvim',
  'kevinhwang91/promise-async',
  'kkharji/sqlite.lua',
  'tpope/vim-rhubarb',
  -- { 'lewis6991/fileline.nvim', lazy = false },
  -- { 'axlebedev/vim-footprints', lazy = false },
  { 'stevearc/profile.nvim', cond = not minimal, lazy = false },
  {
    'romainl/vim-cool',
    cond = false,
    event = 'BufReadPre',
    config = function() vim.g.CoolTotalMatches = 1 end,
  },
  {
    'olimorris/persisted.nvim',
    cond = not minimal,
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
    'neuromaancer/readup.nvim',
    cmd = { 'Readup', 'ReadupBrowser' },
    opts = { float = true },
  },
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
  -- Config Time
  { 'sammce/fleeting.nvim', cond = not minimal and niceties, lazy = false },
  {
    'mrquantumcodes/configpulse',
    cond = not minimal and niceties,
    lazy = false,
  },
  {
    'blumaa/ohne-accidents',
    cond = not minimal and niceties,
    cmd = { 'OhneAccidents' },
    opts = { welcomeOnStartup = false },
  },
  ------------------------------------------------------------------------------
  -- Find And Replace
  {
    'MagicDuck/grug-far.nvim',
    cond = not minimal,
    lazy = false,
    cmd = { 'GrugFar' },
    opts = {
      keymaps = {
        replace = '<C-[>',
        qflist = '<C-q>',
        gotoLocation = '<enter>',
        close = '<C-x>',
      },
    },
  },
  {
    'AckslD/muren.nvim',
    cmd = { 'MurenToggle', 'MurenUnique', 'MurenFresh' },
    opts = {},
  },
  ------------------------------------------------------------------------------
  -- Utilities {{{2
  ------------------------------------------------------------------------------
  { 'lambdalisue/suda.vim', lazy = false },
  { 'will133/vim-dirdiff', cmd = { 'DirDiff' } },
  { 'godlygeek/tabular', cmd = { 'Tabularize' } },
  {
    '4513ECHO/nvim-keycastr',
    cond = not minimal,
    init = function()
      local enabled = false
      local config_set = false
      rvim.command('KeyCastrToggle', function()
        local keycastr = require('keycastr')
        if not config_set then
          keycastr.config.set({
            win_config = { border = 'single' },
            position = 'SE',
          })
          config_set = true
        end
        keycastr[enabled and 'disable' or 'enable']()
        enabled = not enabled
        vim.notify(('Keycastr %s'):format(enabled and 'disabled' or 'enabled'))
      end, {})
      vim.keymap.set(
        'n',
        '<leader>ok',
        '<Cmd>KeyCastrToggle<CR>',
        { desc = 'keycastr: toggle' }
      )
    end,
  },
  {
    'chrishrb/gx.nvim',
    cond = not rvim.use_local_gx and not minimal,
    keys = { { 'gx', '<cmd>Browse<cr>', mode = { 'n', 'x' } } },
    cmd = { 'Browse' },
    init = function() vim.g.netrw_nogx = 1 end,
    opts = {},
    submodules = false,
  },
  {
    'kevinhwang91/nvim-fundo',
    cond = not minimal,
    event = { 'BufRead', 'BufNewFile' },
    build = function() require('fundo').install() end,
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
    'ahmedkhalf/project.nvim',
    cond = not minimal,
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
    cond = not minimal,
    event = { 'BufReadPost', 'BufNewFile' },
    -- stylua: ignore
    config = function()
      local g = require('genghis')
      map('n', '<leader><localleader>fp', g.copyFilepath, { desc = 'genghis: yank filepath' })
      map('n', '<leader><localleader>fn', g.copyFilename, { desc = 'genghis: yank filename' })
      map('n', '<leader><localleader>fr', g.renameFile, { desc = 'genghis: rename file' })
      map('n', '<leader><localleader>fm', g.moveAndRenameFile, { desc = 'genghis: move and rename' })
      map('n', '<leader><localleader>fc', g.createNewFile, { desc = 'genghis: create new file' })
      map('n', '<leader><localleader>fd', g.duplicateFile, { desc = 'genghis: duplicate current file' })
    end,
  },
  {
    'jpalardy/vim-slime',
    cond = not minimal and rvim.plugins.niceties,
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      { '<localleader>sp', '<Plug>SlimeParagraphSend', desc = 'slime: paragraph', },
      { '<localleader>ur', '<Plug>SlimeRegionSend', mode = { 'x' }, desc = 'slime: region', },
      { '<localleader>sc', '<Plug>SlimeConfig', desc = 'slime: config' },
    },
    config = function()
      vim.g.slime_target = 'tmux'
      vim.g.slime_paste_file = vim.fn.stdpath('data') .. '/.slime_paste'
      vim.g.alime_no_mappings = 1
    end,
  },
  {
    'luckasRanarison/nvim-devdocs',
    cond = not minimal,
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
  },
  {
    '2kabhishek/nerdy.nvim',
    cmd = 'Nerdy',
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
    cond = not minimal and rvim.plugins.niceties,
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
  },
  -- }}}
  --------------------------------------------------------------------------------
  -- Share Code
  { 'TobinPalmer/rayso.nvim', cmd = { 'Rayso' }, opts = {} },
  { 'ellisonleao/carbon-now.nvim', cmd = 'CarbonNow', opts = {} },
  { 'Sanix-Darker/snips.nvim', cmd = { 'SnipsCreate' }, opts = {} },
  { 'ethanholz/freeze.nvim', cmd = 'Freeze', opts = {} },
}
