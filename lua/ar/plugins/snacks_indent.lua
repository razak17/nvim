local separators = ar.ui.icons.separators
local ar_indent = ar.config.ui.indentline
local indent_char = separators.left_thin_block

return {
  desc = 'snacks indent',
  recommended = true,
  'folke/snacks.nvim',
  opts = function(_, opts)
    return vim.tbl_deep_extend('force', opts or {}, {
      indent = {
        indent = { enabled = false }, -- show indent lines for current scope only
        enabled = ar_indent.enable and ar_indent.variant == 'snacks',
        char = indent_char,
        only_scope = false, -- only show indent guides of the scope
        only_current = true,
        scope = {
          enabled = true,
          only_current = true,
          char = indent_char,
          hl = 'IndentBlanklineContextChar',
        },
        chunk = {
          enabled = true,
          only_current = true,
          hl = 'IndentBlanklineContextChar',
          char = {
            corner_top = '╭', -- '┌',
            corner_bottom = '╰', --  '└',
            horizontal = '─',
            vertical = '│',
            arrow = '>',
          },
        },
        animate = {
          enabled = vim.fn.has('nvim-0.10') == 1,
          style = 'out',
          easing = 'linear',
          duration = {
            step = 30, -- ms per step
            total = 500, -- maximum duration
          },
        },
      },
    })
  end,
}
