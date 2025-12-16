local minimal = ar.plugins.minimal

return {
  {
    'iamcco/markdown-preview.nvim',
    lazy = false,
    cond = function()
      return ar.get_plugin_cond('markdown-preview.nvim', not minimal)
    end,
    build = function() vim.fn['mkdp#util#install']() end,
    cmd = {
      'MarkdownPreview',
      'MarkdownPreviewStop',
      'MarkdownPreviewToggle',
    },
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    'hat0uma/prelive.nvim',
    cond = function() return ar.get_plugin_cond('prelive.nvim', not minimal) end,
    cmd = {
      'PreLiveGo',
      'PreLiveStatus',
      'PreLiveClose',
      'PreLiveCloseAll',
      'PreLiveLog',
    },
    opts = {},
  },
  {
    'previm/previm',
    cond = function() return ar.get_plugin_cond('previm', not minimal) end,
    ft = { 'markdown' },
    cmd = { 'PrevimOpen', 'PrevimRefresh', 'PrevimWipeCache' },
    config = function()
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
          vim.fn.stdpath('data')
            .. '/lazy/previm/preview/_/css/lib/'
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
}
