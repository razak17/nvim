return {
  desc = 'snacks ui select',
  recommended = true,
  'folke/snacks.nvim',
  opts = function(_, opts)
    local snack_opts = vim.tbl_deep_extend('force', opts or {}, {
      picker = { ui_select = false },
    })
    if ar_config.picker.variant == 'snacks' then
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(items, options, on_choice)
        ---@diagnostic disable-next-line: inject-field
        options.picker = options.picker or {}
        options.picker.layout = {
          preview = false,
          layout = {
            height = math.floor(
              math.min(vim.o.lines * 0.5 - 10, #items + 2) + 0.5
            ),
          },
        }
        require('snacks.picker.select').select(items, options, on_choice)
      end
    end
    return snack_opts
  end,
}
