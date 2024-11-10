local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  ------------------------------------------------------------------------------
  -- Core {{{1
  ------------------------------------------------------------------------------
  'nvim-lua/plenary.nvim',
  'MunifTanjim/nui.nvim',
  'b0o/schemastore.nvim',
  'kevinhwang91/promise-async',
  'kkharji/sqlite.lua',
  'tpope/vim-rhubarb',
  { 'tyru/capture.vim', cmd = { 'Capture' } },
  { 'jghauser/mkdir.nvim', lazy = false },
  { 'Rasukarusan/nvim-block-paste', cmd = { 'Block' } },
  {
    'ryoppippi/nvim-reset',
    cond = false,
    opts = {
      create_plugin_keymap = false,
      ignore_maps = {},
    },
  },
  {
    'smjonas/live-command.nvim',
    cond = not minimal,
    event = 'VeryLazy',
    opts = {
      commands = {
        Norm = { cmd = 'norm' },
      },
    },
    config = function(_, opt) require('live-command').setup(opt) end,
  },
  {
    'tpope/vim-eunuch',
    cmd = {
      'Cfind',
      'Chmod',
      'Clocate',
      'Copy',
      'Delete',
      'Duplicate',
      'Lfind',
      'Llocate',
      'Mkdir',
      'Move',
      'Remove',
      'Rename',
      'SudoEdit',
      'SudoWrite',
      'Wall',
    },
  },
  -- { 'lewis6991/fileline.nvim', lazy = false },
  -- { 'axlebedev/vim-footprints', lazy = false },
  {
    'altermo/nwm',
    branch = 'x11',
    cond = not minimal and niceties,
    lazy = false,
  },
  {
    'yuratomo/w3m.vim',
    cond = not minimal and niceties,
    event = 'VeryLazy',
    init = function()
      local function w3m_input(cmd)
        vim.ui.input(
          { prompt = 'Enter url:', kind = 'center_win' },
          function(input)
            if input ~= nil then vim.cmd(cmd .. ' ' .. input) end
          end
        )
      end

      ar.add_to_menu('w3m', {
        ['Search in vsplit'] = function() w3m_input('W3mVSplit') end,
        ['Search in split'] = function() w3m_input('W3mVSplit') end,
        ['DuckDuckGo Search'] = function() w3m_input('W3m duck') end,
        ['Google Search'] = function() w3m_input('W3m google') end,
        ['Copy URL'] = 'W3mCopyUrl',
        ['Reload Page'] = 'W3mReload',
        ['Change URL'] = 'W3mAddressBar',
        ['Search History'] = 'W3mHistory',
        ['Open In External Browser'] = 'W3mShowExtenalBrowser',
        ['Clear Search History'] = 'W3mHistoryClear',
      })
    end,
    config = function() vim.g['w3m#external_browser'] = 'firefox' end,
  },
  {
    'r-cha/encourage.nvim',
    cond = not minimal and niceties,
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
  },
  { 'nvim-tree/nvim-web-devicons', cond = false },
  {
    'stevearc/profile.nvim',
    cond = not minimal,
    lazy = false,
    init = function()
      local should_profile = os.getenv('NVIM_PROFILE')
      if should_profile then
        require('profile').instrument_autocmds()
        if should_profile:lower():match('^start') then
          require('profile').start('*')
        else
          require('profile').instrument('*')
        end
      end

      local function toggle_profile()
        local prof = require('profile')
        if prof.is_recording() then
          prof.stop()
          vim.ui.input({
            prompt = 'Save profile to:',
            completion = 'file',
            default = 'profile.json',
          }, function(filename)
            if filename then
              prof.export(filename)
              vim.notify(string.format('Wrote %s', filename))
            end
          end)
        else
          prof.start('*')
        end
      end
      ar.add_to_menu('command_palette', { ['Toggle Profile'] = toggle_profile })
    end,
  },
  {
    'romainl/vim-cool',
    cond = false,
    event = 'BufReadPre',
    config = function() vim.g.CoolTotalMatches = 1 end,
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
  {
    'pogyomo/submode.nvim',
    cond = false,
    event = 'VeryLazy',
    config = function()
      local submode = require('submode')

      submode.create('WinMove', {
        mode = 'n',
        enter = '<C-w>',
        leave = { 'q', '<ESC>' },
        default = function(register)
          register('h', '<C-w>h')
          register('j', '<C-w>j')
          register('k', '<C-w>k')
          register('l', '<C-w>l')
        end,
      })

      submode.create('LspOperator', {
        mode = 'n',
        enter = '<Space>lo',
        leave = { 'q', '<ESC>' },
        default = function(register)
          register('d', vim.lsp.buf.definition)
          register('D', vim.lsp.buf.declaration)
          register('H', vim.lsp.buf.hover)
          register('i', vim.lsp.buf.implementation)
          register('r', vim.lsp.buf.references)
        end,
      })
    end,
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Utilities {{{2
  ------------------------------------------------------------------------------
  { 'meznaric/key-analyzer.nvim', cmd = { 'KeyAnalyzer' }, opts = {} },
  {
    'lambdalisue/suda.vim',
    lazy = false,
    init = function()
      ar.add_to_menu('command_palette', {
        ['Re-open File With Sudo Permissions'] = 'SudaRead',
        ['Write File With Sudo Permissions'] = 'SudaWrite',
      })
    end,
  },
  { 'will133/vim-dirdiff', cmd = { 'DirDiff' } },
  { 'godlygeek/tabular', cmd = { 'Tabularize' } },
  { 'ragnarok22/whereami.nvim', cmd = 'Whereami' },
  {
    '2kabhishek/nerdy.nvim',
    cmd = 'Nerdy',
    cond = not minimal,
    init = function()
      ar.add_to_menu('command_palette', { ['Nerdy'] = 'Nerdy' })
    end,
  },
  {
    'AndrewRadev/linediff.vim',
    cond = not minimal,
    cmd = 'Linediff',
    keys = {
      { '<localleader>lL', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
    },
  },
  {
    'ahmedkhalf/project.nvim',
    cond = not minimal,
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
    init = function()
      require('which-key').add({
        { '<leader><localleader>f', group = 'Genghis' },
      })
    end,
    -- stylua: ignore
    config = function()
      local g = require('genghis')
      map('n', '<leader><localleader>fp', g.copyFilepath, { desc = 'genghis: yank filepath' })
      map('n', '<leader><localleader>ff', g.copyFilename, { desc = 'genghis: yank filename' })
      map('n', '<leader><localleader>fr', g.renameFile, { desc = 'genghis: rename file' })
      map('n', '<leader><localleader>fm', g.moveAndRenameFile, { desc = 'genghis: move and rename' })
      map('n', '<leader><localleader>fn', g.createNewFile, { desc = 'genghis: create new file' })
      map('n', '<leader><localleader>fD', g.duplicateFile, { desc = 'genghis: duplicate current file' })
      map(
        'n',
        '<leader><localleader>fd',
        function ()
          vim.ui.input({
            prompt = 'Delete file? (y/n) ',
          }, function(input)
            if input == 'y' or input == 'Y' then g.trashFile() end
          end)
        end,
        { desc = 'genghis: move to trash' }
      )
    end,
  },
  {
    'jpalardy/vim-slime',
    cond = not minimal and ar.plugins.niceties,
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      { '<localleader>sp', '<Plug>SlimeParagraphSend', desc = 'slime: paragraph', },
      { '<localleader>sr', '<Plug>SlimeRegionSend', mode = { 'x' }, desc = 'slime: region', },
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
    init = function()
      require('which-key').add({ { '<localleader>v', group = 'Devdocs' } })
    end,
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
    'razak17/readonly.nvim',
    cond = not minimal and niceties,
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
}
