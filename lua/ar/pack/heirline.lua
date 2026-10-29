local statusline = ar.config.ui.statusline
local statuscolumn = ar.config.ui.statuscolumn

ar.pack.add({
  {
    src = 'https://github.com/rebelot/heirline.nvim',
    event = 'BufWinEnter',
    cond = function()
      local has_variant = statusline.variant == 'heirline'
        or statuscolumn.variant == 'heirline'
      local condition = statusline.enable and has_variant
      return ar.get_plugin_cond('heirline.nvim', condition)
    end,
    init = function()
      ar.augroup('Heirline', {
        event = 'ColorScheme',
        command = function(arg)
          if not package.loaded.heirline then return end
          local theming = require('ar.theming')
          local utils = require('heirline.utils')
          utils.on_colorscheme(theming.get_statusline_palette(arg.match))
        end,
      })
    end,
    setup = function()
      local opts = {
        opts = {
          colors = function()
            return require('ar.theming').get_statusline_palette(
              vim.g.colors_name or ar.config.colorscheme.name
            )
          end,
        },
      }
      local modules = ar.config.plugins.modules
      for _, module in ipairs({ 'heirline-statuscolumn', 'heirline-statusline' }) do
        local disabled = vim.tbl_contains(modules.disabled, module)
        local included = #modules.override == 0
          or vim.tbl_contains(modules.override, module)
        if included and not disabled then
          opts = require('ar.pack.' .. module)(opts)
        end
      end
      require('heirline').setup(opts)
    end,
  },
})
