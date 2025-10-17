local get_cond = ar.get_plugin_cond
local minimal = ar.plugins.minimal

local function inc(mode)
  return function() require('dial.map').manipulate('increment', mode) end
end

local function dec(mode)
  return function() require('dial.map').manipulate('decrement', mode) end
end

return {
  {
    'monaqa/dial.nvim',
    cond = function() return get_cond('dial.nvim', not minimal) end,
    keys = {
      { '<C-a>', inc('normal'), desc = 'dial: increment' },
      { '<C-x>', dec('normal'), desc = 'dial: decrement' },
      { 'g<C-a>', inc('gnormal'), desc = 'dial: gincrement' },
      { 'g<C-x>', dec('gnormal'), desc = 'dial: gdecrement' },
      { mode = { 'x' }, '<C-a>', inc('visual'), desc = 'dial: vincrement' },
      { mode = { 'x' }, '<C-x>', dec('visual'), desc = 'dial: vdecrement' },
      { mode = { 'x' }, 'g<C-a>', inc('gvisual'), desc = 'dial: gvincrement' },
      { mode = { 'x' }, 'g<C-x>', dec('gvisual'), desc = 'dial: gvdecrement' },
    },
    config = function()
      local augend = require('dial.augend')
      local config = require('dial.config')

      local default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.integer.alias.binary,
        augend.date.alias['%Y/%m/%d'],
        augend.date.alias['%Y-%m-%d'],
        augend.date.alias['%H:%M:%S'],
        augend.date.alias['%-m/%-d'],
        augend.constant.alias.de_weekday,
        augend.constant.alias.de_weekday_full,
        augend.hexcolor.new({ case = 'lower' }),
        augend.semver.alias.semver,
        augend.constant.new({ elements = { 'true', 'false' }, cyclic = true }),
        augend.case.new({
          types = {
            'camelCase',
            'snake_case',
            'PascalCase',
            'SCREAMING_SNAKE_CASE',
          },
          cyclic = true,
        }),
      }

      config.augends:register_group({ default = default })

      local operators = augend.constant.new({
        elements = { '&&', '||' },
        word = false,
        cyclic = true,
      })

      config.augends:on_filetype({
        go = vim.iter({ default, { operators } }):flatten():totable(),
      })

      config.augends:on_filetype({
        markdown = vim
          .iter({ default, { augend.misc.alias.markdown_header } })
          :flatten()
          :totable(),
      })

      local bool = augend.constant.new({
        elements = { 'True', 'False' },
        cyclic = true,
      })

      config.augends:on_filetype({
        python = vim.iter({ default, { bool } }):flatten():totable(),
      })

      local ts = vim
        .iter({
          default,
          {
            augend.integer.alias.decimal,
            augend.integer.alias.hex,
            augend.paren.alias.quote,
            augend.constant.new({ elements = { 'let', 'const' } }),
          },
        })
        :flatten()
        :totable()

      vim
        .iter({
          'typescript',
          'javascript',
          'typescriptreact',
          'javascriptreact',
          'tsx',
          'jsx',
          'svelte',
          'vue',
          'astro',
        })
        :each(function(ft) config.augends:on_filetype({ [ft] = ts }) end)
    end,
  },
}
