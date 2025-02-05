local border = ar.ui.current.border
local minimal = ar.plugins.minimal

return {
  'stevearc/dressing.nvim',
  event = 'BufRead',
  cond = function()
    return not minimal and ar_config.picker.variant == 'telescope'
  end,
  init = function()
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(...)
      require('lazy').load({ plugins = { 'dressing.nvim' } })
      return vim.ui.select(...)
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.input = function(...)
      require('lazy').load({ plugins = { 'dressing.nvim' } })
      return vim.ui.input(...)
    end
  end,
  opts = {
    input = { insert_only = false, border = border },
    select = {
      builtin = {
        border = border,
        min_height = 10,
        win_options = { winblend = 10 },
        mappings = { n = { ['q'] = 'Close' } },
      },
      get_config = function(opts)
        return {
          backend = 'fzf_lua',
          fzf_lua = ar.fzf.dropdown({
            winopts = { title = opts.prompt, height = 0.33, row = 0.5 },
          }),
        }
      end,
      nui = {
        min_height = 10,
        win_options = {
          winhighlight = table.concat({
            'Normal:Italic',
            'FloatBorder:PickerBorder',
            'FloatTitle:Title',
            'CursorLine:Visual',
          }, ','),
        },
      },
    },
  },
  config = function(_, opts)
    require('dressing').setup(opts)
    map('n', 'z=', function()
      local word = vim.fn.expand('<cword>')
      local suggestions = vim.fn.spellsuggest(word)
      vim.ui.select(
        suggestions,
        {},
        vim.schedule_wrap(function(selected)
          if selected then
            vim.cmd.normal({ args = { 'ciw' .. selected }, bang = true })
          end
        end)
      )
    end)
  end,
}
