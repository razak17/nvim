local minimal = ar.plugins.minimal

local function get_cond()
  local condition = ar.completion.enable and not minimal
  return ar.get_plugin_cond('nvim-px-to-rem', condition)
end

return {
  {
    {
      'jsongerber/nvim-px-to-rem',
      ft = {
        'css',
        'scss',
        'less',
        'html',
        'javascript',
        'typescript',
        'javascriptreact',
        'typescriptreact',
      },
      cond = get_cond,
      cmd = { 'PxToRemCursor', 'PxToRemLine' },
      opts = {},
    },
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        return get_cond()
            and vim.g.blink_add_source({ 'nvim-px-to-rem' }, {
              ['nvim-px-to-rem'] = {
                module = 'nvim-px-to-rem.integrations.blink',
                name = '[PX2REM]',
              },
            }, opts)
          or opts
      end,
    },
    {
      'hrsh7th/nvim-cmp',
      optional = true,
      opts = function(_, opts)
        vim.g.cmp_add_source(opts, {
          source = {
            name = 'nvim_px_to_rem',
            group_index = 1,
            priority = 100,
          },
          menu = { nvim_px_to_rem = '[PX2REM]' },
          format = {
            nvim_px_to_rem = {
              icon = ar.ui.codicons.misc.hash,
              hl = 'CmpItemKindNerdFont',
            },
          },
        })
      end,
    },
  },
}
