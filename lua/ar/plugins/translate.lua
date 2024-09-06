local minimal = ar.plugins.minimal

return {
  -- Translate
  --------------------------------------------------------------------------------
  {
    'potamides/pantran.nvim',
    cond = not minimal,
    keys = {
      {
        '<leader><leader>tm',
        function() return require('pantran').motion_translate() end,
        mode = { 'n', 'x' },
        expr = true,
        desc = 'motion',
      },
      {
        '<leader><leader>tp',
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
    cond = not minimal,
    cmd = { 'CrowTranslate' },
    opts = {
      language = 'es',
      default = 'en',
      engine = 'google',
    },
  },
}
