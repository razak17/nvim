local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
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
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'luckasRanarison/nvim-devdocs',
    cond = not minimal and false,
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>v', group = 'Devdocs' })
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
}
