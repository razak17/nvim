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
  { 'Rasukarusan/nvim-block-paste', cmd = { 'Block' } },
  { 'dundalek/bloat.nvim', cmd = 'Bloat' },
  {
    'ariel-frischer/bmessages.nvim',
    cond = not minimal,
    cmd = { 'Bmessages', 'Bmessagesvs', 'Bmessagessp', 'BmessagesEdit' },
    event = 'CmdlineEnter',
    opts = {},
  },
  {
    'smjonas/live-command.nvim',
    cond = not minimal,
    event = 'VeryLazy',
    opts = {
      commands = {
        Norm = { cmd = 'norm' },
        G = { cmd = 'g' },
        D = { cmd = 'd' },
        LSubvert = { cmd = 'Subvert' },
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

      ar.add_to_select_menu('w3m', {
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
      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle Profile'] = toggle_profile }
      )
    end,
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
  -- Utilities {{{2
  ------------------------------------------------------------------------------
  { 'meznaric/key-analyzer.nvim', cmd = { 'KeyAnalyzer' }, opts = {} },
  {
    'crixuamg/visual-complexity.nvim',
    cmd = { 'VisualComplexity', 'ToggleComplexityReasons' },
    opts = {},
  },
  {
    'mikesmithgh/kitty-scrollback.nvim',
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    config = function()
      require('kitty-scrollback').setup({
        {
          callbacks = {
            after_ready = vim.defer_fn(
              function()
                vim.fn.confirm(
                  vim.env.NVIM_APPNAME .. ' kitty-scrollback.nvim example!'
                )
              end,
              1000
            ),
          },
        },
      })
    end,
  },
  {
    'lambdalisue/suda.vim',
    cond = not ar.plugin_disabled('suda.vim') and false,
    lazy = false,
    init = function()
      ar.add_to_select_menu('command_palette', {
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
      ar.add_to_select_menu('command_palette', { ['Nerdy'] = 'Nerdy' })
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
      vim.g.whichkey_add_spec({ '<leader><localleader>f', group = 'Genghis' })
    end,
    -- stylua: ignore
    keys = {
      { '<leader><localleader>fp', '<cmd>lua require("genghis").copyFilepath()<CR>', desc = 'genghis: yank filepath' },
      { '<leader><localleader>ff', '<cmd>lua require("genghis").copyFilename()<CR>', desc = 'genghis: yank filename' },
      { '<leader><localleader>fr', '<cmd>lua require("genghis").renameFile()<CR>', desc = 'genghis: rename file' },
      { '<leader><localleader>fm', '<cmd>lua require("genghis").moveAndRenameFile()<CR>', desc = 'genghis: move and rename' },
      { '<leader><localleader>fn', '<cmd>lua require("genghis").createNewFile()<CR>', desc = 'genghis: create new file' },
      { '<leader><localleader>fD', '<cmd>lua require("genghis").duplicateFile()<CR>', desc = 'genghis: duplicate current file' },
      {
        '<leader><localleader>fd',
        function ()
          if vim.fn.confirm('Delete file?', '&Yes\n&No') == 1 then
            require('genghis').trashFile()
          end
        end,
        desc = 'genghis: move to trash',
      },
    },
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
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  -- { 'lewis6991/fileline.nvim', lazy = false },
  -- { 'axlebedev/vim-footprints', lazy = false },
  { 'nvim-tree/nvim-web-devicons', cond = false },
  { 'jghauser/mkdir.nvim', enabled = false, lazy = false },
  { 'gcanoxl/cloc.nvim', cond = false, opts = {} },
  {
    'romainl/vim-cool',
    cond = false,
    event = 'BufReadPre',
    config = function() vim.g.CoolTotalMatches = 1 end,
  },
  {
    'ryoppippi/nvim-reset',
    cond = false,
    opts = {
      create_plugin_keymap = false,
      ignore_maps = {},
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
}
