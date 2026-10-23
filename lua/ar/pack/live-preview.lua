ar.pack.add({
  --------------------------------------------------------------------------------
  -- Markdown
  --------------------------------------------------------------------------------
  {
    src = 'https://github.com/selimacerbas/mdkite.nvim',
    cond = function()
      return ar.get_plugin_cond('mdkite.nvim', not ar.plugins.minimal)
    end,
    cmd = { 'MdKite' },
    setup = function() require('mdkite').setup() end,
    dependencies = {
      {
        src = 'https://github.com/selimacerbas/kitehost.nvim',
        setup = function() require('kitehost').setup() end,
      },
    },
  },
  {
    src = 'https://github.com/wallpants/github-preview.nvim',
    cond = function()
      return ar.get_plugin_cond('github-preview.nvim', not ar.plugins.minimal)
    end,
    build = function(event)
      local result = vim
        .system(
          { 'bun', 'install', '--frozen-lockfile' },
          { cwd = event.data.path, text = true }
        )
        :wait()
      if result.code ~= 0 then
        error('github-preview build failed: ' .. (result.stderr or ''))
      end
    end,
    cmd = { 'GithubPreviewStart', 'GithubPreviewStop', 'GithubPreviewToggle' },
    setup = function() require('github-preview').setup() end,
  },
  {
    src = 'https://github.com/blackhat-7/vellum.nvim',
    cond = function() return ar.get_plugin_cond('vellum.nvim') end,
    cmd = { 'Vellum' },
    build = function(event)
      vim.notify('vellum.nvim: building renderer…')
      dofile(event.data.path .. '/build.lua')
      vim.notify('vellum.nvim: build done')
    end,
    setup = function() require('vellum').setup() end,
  },
  {
    src = 'https://github.com/mariocesar/beside.nvim',
    cond = function() return ar.get_plugin_cond('beside.nvim') end,
    cmd = { 'Beside' },
    setup = function() require('beside').setup() end,
  },
  {
    src = 'https://github.com/wallpants/previm/previm',
    cond = function()
      return ar.get_plugin_cond('previm', not ar.plugins.minimal)
    end,
    cmd = { 'PrevimOpen', 'PrevimRefresh', 'PrevimWipeCache' },
    setup = function()
      vim.g.previm_open_cmd = 'zen'
      vim.g.previm_enable_realtime = 0
      vim.g.previm_code_language_show = 1
      vim.g.previm_disable_default_css = 1
      vim.g.previm_custom_css_path = vim.fn.stdpath('config')
        .. '/css/previm-gh-dark.css'
      local hljs_ghdark_css = 'highlight-gh-dark.css'
      vim.g.previm_extra_libraries = {
        {
          name = 'highlight-gh-dark',
          files = {
            {
              type = 'css',
              -- must use previm jailed path due to chrome running in firejail
              path = '_/css/lib/highlight-gh-dark.css',
            },
          },
        },
      }
      -- Copy our custom code highlight css to the jailbreak folder
      if
        not vim.uv.fs_copyfile(
          vim.fn.stdpath('config') .. '/css/' .. hljs_ghdark_css,
          vim.pack.get({ 'previm' })[1].path
            .. '/preview/_/css/lib/'
            .. hljs_ghdark_css
        )
      then
        vim.notify(
          string.format("Unable to copy '%s' to previm jail.", hljs_ghdark_css)
        )
      end
      -- clear cache every time we open neovim
      vim.fn['previm#wipe_cache']()
    end,
  },
  --------------------------------------------------------------------------------
  -- HTML
  --------------------------------------------------------------------------------
  {
    src = 'https://github.com/selimacerbas/kitehost.nvim',
    cond = function()
      return ar.get_plugin_cond('kitehost.nvim', not ar.plugins.minimal)
    end,
    cmd = { 'KiteHost' },
    setup = function() require('kitehost').setup() end,
  },
  {
    src = 'https://github.com/brianhuster/live-preview.nvim',
    cond = function() return ar.get_plugin_cond('live-preview') end,
    cmd = { 'LivePreview' },
  },
  {
    src = 'https://github.com/wallpants/hat0uma/prelive.nvim',
    cond = function()
      return ar.get_plugin_cond('prelive.nvim', not ar.plugins.minimal)
    end,
    cmd = {
      'PreLiveGo',
      'PreLiveStatus',
      'PreLiveClose',
      'PreLiveCloseAll',
      'PreLiveLog',
    },
    setup = function() require('prelive').setup() end,
  },
})
