local border = ar.ui.current.border.default

return {
  {
    'razak17/tailwind-fold.nvim',
    cond = function()
      if not ar.lsp.enable then
        return ar.get_plugin_cond('tailwind-fold.nvim')
      end
      local condition = not ar.config.lsp.lang.tailwind['tailwind-tools']
      return ar.get_plugin_cond('tailwind-fold.nvim', condition)
    end,
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Tailwind Fold'] = 'TailwindFoldToggle',
      })
    end,
    cmd = {
      'TailwindFoldToggle',
      'TailwindFoldEnable',
      'TailwindFoldDisable',
    },
    opts = { min_chars = 5, symbol = '󱏿' },
    ft = {
      'html',
      'clojure',
      'svelte',
      'astro',
      'vue',
      'typescriptreact',
      'javascriptreact',
      'php',
      'blade',
      'eruby',
      'htmlangular',
      'htmldjango',
      'templ',
      'cshtml',
      'razor',
    },
  },
  {
    'luckasRanarison/tailwind-tools.nvim',
    cond = function()
      local condition = ar.lsp.enable
        and ar.config.lsp.lang.tailwind['tailwind-tools']
      return ar.get_plugin_cond('tailwind-fold.nvim', condition)
    end,
    ft = {
      'html',
      'svelte',
      'astro',
      'vue',
      'typescriptreact',
      'javascriptreact',
      'htmlangular',
      'php',
      'blade',
    },
    event = { 'BufRead' },
    cmd = {
      'TailwindConcealToggle',
      'TailwindColorToggle',
      'TailwindSort',
      'TailwindSortSelection',
    },
    init = function()
      ar.add_to_select_menu('lsp', {
        ['Toggle Tailwind Tools Fold'] = 'TailwindConcealToggle',
        ['Toggle Tailwind Colors'] = 'TailwindColorToggle',
        ['Sort Tailwind Classes'] = 'TailwindSort',
      })
    end,
    opts = {
      document_color = {
        enabled = false,
        inline_symbol = ar.ui.icons.misc.block_medium .. ' ',
      },
      conceal = {
        enabled = true,
        symbol = '󱏿',
        min_length = 5,
        highlight = { fg = '#38BDF8' },
      },
    },
  },
  {
    'MaximilianLloyd/tw-values.nvim',
    cond = function()
      return ar.get_plugin_cond('tw-values.nvim', ar.lsp.enable)
    end,
    cmd = { 'TWValues' },
    -- stylua: ignore
    keys = {
      { '<localleader>lt', '<Cmd>TWValues<cr>', desc = 'tw-values: show values', },
    },
    opts = { border = border, show_unknown_classes = true },
  },
  {
    -- 'atiladefreitas/tinyunit',
    'razak17/tinyunit',
    cond = function() return ar.get_plugin_cond('tinyunit') end,
    keys = {
      { mode = { 'n', 'x' }, '<leader>ux', desc = 'tinyunit: open' },
    },
    opts = {
      keymap = { open = 'ux', close = 'q' },
    },
  },
}
