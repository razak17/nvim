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
    cond = function() return ar.get_plugin_cond('bmessages.nvim', not minimal) end,
    cmd = { 'Bmessages', 'Bmessagesvs', 'Bmessagessp', 'BmessagesEdit' },
    event = 'CmdlineEnter',
    opts = {},
  },
  {
    'smjonas/live-command.nvim',
    cond = function()
      return ar.get_plugin_cond('live-command.nvim', not minimal)
    end,
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
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('nwm', condition)
    end,
    lazy = false,
  },
  {
    'yuratomo/w3m.vim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('w3m.vim', condition)
    end,
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
    'stevearc/profile.nvim',
    cond = function() return ar.get_plugin_cond('profile.nvim', not minimal) end,
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
    cond = function() return ar.get_plugin_cond('readline.nvim') end,
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
    cond = function() return ar.get_plugin_cond('suda.vim', false) end,
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
    cond = function() return ar.get_plugin_cond('nerdy.nvim', not minimal) end,
    init = function()
      ar.add_to_select_menu('command_palette', { ['Nerdy'] = 'Nerdy' })
    end,
  },
  {
    'AndrewRadev/linediff.vim',
    cond = function() return ar.get_plugin_cond('linediff.vim', not minimal) end,
    cmd = 'Linediff',
    keys = {
      { '<localleader>lL', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
    },
  },
  {
    'ahmedkhalf/project.nvim',
    cond = function() return ar.get_plugin_cond('project.nvim', not minimal) end,
    name = 'project_nvim',
    opts = {
      detection_methods = { 'pattern', 'lsp' },
      ignore_lsp = { 'null-ls' },
      patterns = { '.git' },
    },
  },
  {
    'chrisgrieser/nvim-genghis',
    cond = function() return ar.get_plugin_cond('nvim-genghis', not minimal) end,
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
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('vim-slime', condition)
    end,
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
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('readonly.nvim', condition)
    end,
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
  {
    'willothy/flatten.nvim',
    lazy = false,
    cond = function()
      local condition = not minimal and ar_config.flatten.enable
      return ar.get_plugin_cond('flatten.nvim', condition)
    end,
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
  -- }}}
}
