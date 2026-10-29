ar.pack.add({
  {
    src = 'https://github.com/emmanueltouzery/apidocs.nvim',
    cond = function()
      return ar.get_plugin_cond('apidocs.nvim', not ar.plugins.minimal)
    end,
    cmd = { 'ApidocsInstall', 'ApidocsOpen', 'ApidocsSearch' },
    setup = function() require('apidocs').setup() end,
  },
  {
    src = 'https://github.com/maskudo/devdocs.nvim',
    cond = function()
      return ar.get_plugin_cond('devdocs.nvim', not ar.plugins.minimal)
    end,
    -- lazy = false,
    cmd = { 'DevDocs' },
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>v', group = 'DevDocs' })
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>vo', mode = 'n', '<cmd>DevDocs get<cr>', desc = 'devdocs: get' },
      { '<localleader>vi', mode = 'n', '<cmd>DevDocs install<cr>', desc = 'devdocs: install' },
    },
    setup = function()
      require('devdocs').setup({
        ensure_installed = {
          'bash',
          'css',
          'docker~17',
          'dom',
          'go',
          'html',
          'http',
          'javascript',
          'lua~5.1',
          -- 'tailwindcss',
          'typescript',
          -- 'rust',
        },
      })
    end,
  },
})
