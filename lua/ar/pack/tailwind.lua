local border = ar.ui.current.border.default

ar.pack.add({
  {
    src = 'https://github.com/razak17/tailwind-fold.nvim',
    cond = function()
      if not ar.lsp.enable then
        return ar.get_plugin_cond('tailwind-fold.nvim')
      end
      local condition = not ar.config.lsp.lang.tailwind['tailwind-tools']
      return ar.get_plugin_cond('tailwind-fold.nvim', condition)
    end,
    init = function()
      ar.add_to_select('toggle', {
        ['Toggle Tailwind Fold'] = 'TailwindFoldToggle',
      })
    end,
    cmd = {
      'TailwindFoldToggle',
      'TailwindFoldEnable',
      'TailwindFoldDisable',
    },
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
    setup = function()
      require('tailwind-fold').setup({
        min_chars = 5,
        symbol = '󱏿',
        on_toggle = function(enabled)
          vim.notify(
            string.format('tailwind fold %s', ar.bool2str(enabled)),
            vim.log.levels.INFO,
            { title = 'Tailwind Fold' }
          )
        end,
      })
    end,
  },
  {
    src = 'https://github.com/luckasRanarison/tailwind-tools.nvim',
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
      ar.add_to_select('lsp', {
        ['Toggle Tailwind Tools Fold'] = 'TailwindConcealToggle',
        ['Toggle Tailwind Colors'] = 'TailwindColorToggle',
        ['Sort Tailwind Classes'] = 'TailwindSort',
      })
    end,
    setup = function()
      require('tailwind-tools').setup({
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
      })
    end,
  },
  {
    src = 'https://github.com/MaximilianLloyd/tw-values.nvim',
    cond = function()
      return ar.get_plugin_cond('tw-values.nvim', ar.lsp.enable)
    end,
    cmd = { 'TWValues' },
    keys = {
      {
        '<localleader>lt',
        '<Cmd>TWValues<cr>',
        desc = 'tw-values: show values',
      },
    },
    setup = function()
      require('tw-values').setup({
        border = border,
        show_unknown_classes = true,
      })
    end,
  },
  {
    src = 'https://github.com/razak17/tinyunit',
    cond = function() return ar.get_plugin_cond('tinyunit') end,
    keys = {
      { mode = { 'n', 'x' }, '<leader>ux', desc = 'tinyunit: open' },
    },
    setup = function()
      require('tinyunit').setup({
        keymap = { open = 'ux', close = 'q' },
      })
    end,
  },
  {
    src = 'https://github.com/ruicsh/tailwindcss-shades.nvim',
    cond = function() return ar.get_plugin_cond('tailwindcss-shades.nvim') end,
    cmd = { 'TailwindShadesGenerate', 'TailwindShadesGenerateCSSVars' },
    setup = function() require('tailwindcss-shades').setup() end,
  },
})
