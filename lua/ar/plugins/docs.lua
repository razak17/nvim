local minimal = ar.plugins.minimal

return {
  {
    'emmanueltouzery/apidocs.nvim',
    cmd = { 'ApidocsInstall', 'ApidocsOpen' },
    opts = {},
  },
  {
    'maskudo/devdocs.nvim',
    cond = not minimal,
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
    opts = {
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
    },
  },
}
