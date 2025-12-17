local minimal = ar.plugins.minimal

return {
  -- Translate
  --------------------------------------------------------------------------------
  {
    'acidsugarx/babel.nvim',
    version = '*',
    cond = function() return ar.get_plugin_cond('babel.nvim', not minimal) end,
    cmd = { 'Babel', 'BabelWord' },
    opts = {
      display = 'picker', -- "float" or "picker"
      picker = 'snacks', -- "auto", "telescope", "fzf", "snacks", "mini"
      target = 'de',
      float = {
        border = vim.o.winborder,
        max_width = 80,
        max_height = 240,
      },
      keymaps = { translate = '<leader>tr', translate_word = '<leader>tw' },
    },
    keys = {
      { '<leader>tr', mode = 'x', desc = 'babel: translate selection' },
      { '<leader>tw', desc = 'babel: translate word' },
    },
  },
  {
    'potamides/pantran.nvim',
    cond = function() return ar.get_plugin_cond('pantran.nvim', not minimal) end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader><leader>T', group = 'Translate' })
    end,
    keys = {
      {
        '<leader><leader>Tm',
        function() return require('pantran').motion_translate() end,
        mode = { 'n', 'x' },
        expr = true,
        desc = 'motion',
      },
      {
        '<leader><leader>Tp',
        '<cmd>Pantran<CR>',
        mode = { 'n', 'v' },
        desc = 'prompt',
      },
    },
    config = function()
      ar.highlight.plugin('pantran', {
        theme = {
          ['onedark'] = { { PantranBorder = { inherit = 'FloatBorder' } } },
        },
      })

      local default_source = 'auto'
      local default_target = 'es'
      require('pantran').setup({
        default_engine = 'argos',
        engines = {
          argos = {
            default_source = default_source,
            default_target = default_target,
          },
          apertium = {
            default_source = default_source,
            default_target = default_target,
          },
          yandex = {
            default_source = default_source,
            default_target = default_target,
          },
          google = {
            default_source = default_source,
            default_target = default_target,
          },
        },
      })
    end,
  },
  {
    'coffebar/crowtranslate.nvim',
    cond = function()
      return ar.get_plugin_cond('crowtranslate.nvim', not minimal)
    end,
    cmd = { 'CrowTranslate' },
    opts = {
      language = 'es',
      default = 'en',
      engine = 'google',
    },
  },
}
