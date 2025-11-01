local minimal = ar.plugins.minimal

return {
  {
    'mhanberg/output-panel.nvim',
    init = function()
      ar.add_to_select_menu('lsp', { ['Output Panel'] = 'OutputPanel' })
    end,
    event = 'LspAttach',
    cond = not minimal and ar.lsp.enable,
    cmd = { 'OutputPanel' },
    opts = {},
    config = function(_, opts) require('output_panel').setup(opts) end,
  },
  {
    'icholy/lsplinks.nvim',
    event = 'LspAttach',
    cond = ar.lsp.enable,
    opts = {},
  },
  {
    'chrisgrieser/nvim-rulebook',
    cond = ar.lsp.enable,
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
    opts = {
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
    },
  },
  {
    'zeioth/garbage-day.nvim',
    cond = function()
      local condition = ar.lsp.enable
      return ar.get_plugin_cond('garbage-day.nvim', condition)
    end,
    event = 'LspAttach',
    opts = {
      grace_period = 60 * 15,
      notifications = true,
      excluded_languages = { 'java', 'markdown' },
    },
  },
  {
    'stevanmilic/nvim-lspimport',
    cond = ar.lsp.enable,
    ft = { 'python' },
    -- stylua: ignore
    keys = {
      { '<localleader>ll', function() require('lspimport').import() end, desc = 'lsp-import: import (python)' },
    },
  },
}
