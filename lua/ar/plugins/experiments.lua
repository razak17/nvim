local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
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
    'mikesmithgh/kitty-scrollback.nvim',
    cond = function() return ar.get_plugin_cond('kitty-scrollback.nvim') end,
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
}
