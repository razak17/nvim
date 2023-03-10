return {
  'monaqa/dial.nvim',
  keys = {
    { '<C-a>', '<Plug>(dial-increment)', mode = 'n' },
    { '<C-x>', '<Plug>(dial-decrement)', mode = 'n' },
    { '<C-a>', '<Plug>(dial-increment)', mode = 'v' },
    { '<C-x>', '<Plug>(dial-decrement)', mode = 'v' },
    { 'g<C-a>', 'g<Plug>(dial-increment)', mode = 'v' },
    { 'g<C-x>', 'g<Plug>(dial-decrement)', mode = 'v' },
  },
  config = function()
    local augend = require('dial.augend')
    local config = require('dial.config')

    local operators = augend.constant.new({
      elements = { '&&', '||' },
      word = false,
      cyclic = true,
    })

    config.augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias['%Y/%m/%d'],
      },
    })

    config.augends:on_filetype({
      go = { augend.integer.alias.decimal, augend.integer.alias.hex, operators },
      typescript = { augend.integer.alias.decimal, augend.integer.alias.hex },
      markdown = { augend.integer.alias.decimal, augend.misc.alias.markdown_header },
      yaml = { augend.semver.alias.semver },
      toml = { augend.semver.alias.semver },
    })
  end,
}
