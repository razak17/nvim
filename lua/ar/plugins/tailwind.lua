local border = ar.ui.current.border

return {
  {
    'razak17/tailwind-fold.nvim',
    cond = function()
      if not ar.lsp.enable then
        return ar.get_plugin_cond('tailwind-fold.nvim')
      end
      local condition = not ar_config.lsp.lang.tailwind['tailwind-tools']
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
        and ar_config.lsp.lang.tailwind['tailwind-tools']
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
    -- stylua: ignore
    keys = {
      { '<localleader>lt', '<Cmd>TWValues<cr>', desc = 'tw-values: show values', },
    },
    opts = { border = border, show_unknown_classes = true },
  },
  {
    'atiladefreitas/tinyunit',
    keys = {
      { '<leader>tu', desc = 'tinyunit: open', mode = { 'n', 'x' } },
    },
    opts = {
      keymap = {
        open = 'tu',
        close = 'q',
      },
    },
  },
}
