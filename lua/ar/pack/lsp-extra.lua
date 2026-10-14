ar.pack.add({
  {
    src = 'https://github.com/chrisgrieser/nvim-rulebook',
    cond = function() return ar.get_plugin_cond('nvim-rulebook') end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader>l?', group = 'Rulebook' })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>l?f', function() require('rulebook').suppressFormatter() end, mode = { 'n', 'x' }, desc = 'rulebook: formatter suppress' },
      { '<leader>l?i', function() require('rulebook').ignoreRule() end, desc = 'rulebook: ignore rule' },
      { '<leader>l?l', function() require('rulebook').lookupRule() end, desc = 'rulebook: lookup rule' },
      { '<leader>l?y', function() require('rulebook').yankDiagnosticCode() end, desc = 'rulebook: yank diagnostic code' },
    },
    cmd = { 'Rulebook' },
    setup = function()
      require('rulebook').setup({
        suppressFormatter = {
          -- use `biome` instead of `prettier`
          javascript = {
            location = 'prevLine',
            ignoreBlock = '// biome-ignore format: expl',
          },
          typescript = {
            location = 'prevLine',
            ignoreBlock = '// biome-ignore format: expl',
          },
          css = {
            location = 'prevLine',
            ignoreBlock = '/* biome-ignore format: expl */',
          },
        },
      })
    end,
  },
  {
    src = 'https://github.com/mhanberg/output-panel.nvim',
    init = function()
      ar.add_to_select('lsp', { ['Output Panel'] = 'OutputPanel' })
    end,
    event = 'LspAttach',
    cond = function()
      local condition = not ar.plugins.minimal and ar.lsp.enable
      return ar.get_plugin_cond('output-panel.nvim', condition)
    end,
    cmd = { 'OutputPanel' },
    setup = function() require('output_panel').setup() end,
  },
  {
    src = 'https://github.com/stevanmilic/nvim-lspimport',
    cond = function()
      return ar.get_plugin_cond('nvim-lspimport', ar.lsp.enable)
    end,
    ft = { 'python' },
    -- stylua: ignore
    keys = {
      { '<localleader>ll', function() require('lspimport').import() end, desc = 'lsp-import: import (python)' },
    },
  },
  {
    src = 'https://github.com/icholy/lsplinks.nvim',
    event = 'LspAttach',
    cond = function() return ar.get_plugin_cond('lsplinks.nvim', ar.lsp.enable) end,
    setup = function() require('lsplinks').setup() end,
  },
  {
    src = 'https://github.com/zeioth/garbage-day.nvim',
    cond = function()
      return ar.get_plugin_cond('garbage-day.nvim', ar.lsp.enable)
    end,
    event = 'LspAttach',
    setup = function()
      require('garbage-day').setup({
        grace_period = 60 * 15,
        notifications = true,
        excluded_languages = { 'java', 'markdown' },
      })
    end,
  },
})
