local get_cond = ar.get_plugin_cond
local coding = ar.plugins.coding

local function inc(mode, group_name)
  group_name = group_name or 'default'
  return function()
    require('dial.map').manipulate('increment', mode, group_name)
  end
end

local function dec(mode, group_name)
  group_name = group_name or 'default'
  return function()
    require('dial.map').manipulate('decrement', mode, group_name)
  end
end

return {
  {
    'monaqa/dial.nvim',
    cond = function() return get_cond('dial.nvim', coding) end,
    keys = {
      { '<C-a>', inc('normal'), desc = 'dial: increment' },
      { '<C-x>', dec('normal'), desc = 'dial: decrement' },
      { 'g<C-a>', inc('gnormal'), desc = 'dial: gincrement' },
      { 'g<C-x>', dec('gnormal'), desc = 'dial: gdecrement' },
      { mode = { 'x' }, '<C-a>', inc('visual'), desc = 'dial: vincrement' },
      { mode = { 'x' }, '<C-x>', dec('visual'), desc = 'dial: vdecrement' },
      { mode = { 'x' }, 'g<C-a>', inc('gvisual'), desc = 'dial: gvincrement' },
      { mode = { 'x' }, 'g<C-x>', dec('gvisual'), desc = 'dial: gvdecrement' },
      { '<leader>ii', inc('normal', 'toggler'), desc = 'dial: toggles' },
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

      local const = augend.constant.new
      local toggler = {
        const({ elements = { '==', '~=' }, cyclic = true }),
        const({ elements = { '===', '!==' }, cyclic = true }),
        const({ elements = { '!=', '==' }, cyclic = true }),
        const({ elements = { 'true', 'false' }, cyclic = true }),
        const({ elements = { 'True', 'False' }, cyclic = true }),
        const({ elements = { 'yes', 'no' }, cyclic = true }),
        const({ elements = { 'on', 'off' }, cyclic = true }),
        const({ elements = { 'left', 'right' }, cyclic = true }),
        const({ elements = { 'up', 'down' }, cyclic = true }),
        const({ elements = { 'enable', 'disable' }, cyclic = true }),
        const({ elements = { 'vim', 'emacs' }, cyclic = true }),
        const({ elements = { 'let', 'const' }, cyclic = true }),
        const({ elements = { 'margin', 'padding' }, cyclic = true }),
        const({ elements = { '-', '+' }, cyclic = true }),
        const({ elements = { 'onClick', 'onSubmit' }, cyclic = true }),
        const({ elements = { 'public', 'private' }, cyclic = true }),
        const({ elements = { 'string', 'int' }, cyclic = true }),
        const({ elements = { 'leader', 'localleader' }, cyclic = true }),
        const({ elements = { 'chore', 'feat' }, cyclic = true }),
        const({ elements = { 'double', 'single' }, cyclic = true }),
        const({ elements = { 'config', 'opts' }, cyclic = true }),
        const({ elements = { 'pre', 'post' }, cyclic = true }),
        const({ elements = { 'column', 'row' }, cyclic = true }),
        const({ elements = { 'before', 'after' }, cyclic = true }),
        const({ elements = { 'end', 'start' }, cyclic = true }),
        const({ elements = { 'high', 'low' }, cyclic = true }),
        const({ elements = { 'open', 'close' }, cyclic = true }),
        const({ elements = { 'and', 'or' }, cyclic = true }),
        const({ elements = { 'GET', 'POST' }, cyclic = true }),
      }

      config.augends:register_group({
        default = default,
        toggler = toggler,
      })

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

      local const = augend.constant.new
      local toggler = {
        const({ elements = { '==', '~=' }, cyclic = true }),
        const({ elements = { '===', '!==' }, cyclic = true }),
        const({ elements = { '!=', '==' }, cyclic = true }),
        const({ elements = { 'true', 'false' }, cyclic = true }),
        const({ elements = { 'True', 'False' }, cyclic = true }),
        const({ elements = { 'yes', 'no' }, cyclic = true }),
        const({ elements = { 'on', 'off' }, cyclic = true }),
        const({ elements = { 'left', 'right' }, cyclic = true }),
        const({ elements = { 'up', 'down' }, cyclic = true }),
        const({ elements = { 'enable', 'disable' }, cyclic = true }),
        const({ elements = { 'vim', 'emacs' }, cyclic = true }),
        const({ elements = { 'let', 'const' }, cyclic = true }),
        const({ elements = { 'margin', 'padding' }, cyclic = true }),
        const({ elements = { '-', '+' }, cyclic = true }),
        const({ elements = { 'onClick', 'onSubmit' }, cyclic = true }),
        const({ elements = { 'public', 'private' }, cyclic = true }),
        const({ elements = { 'string', 'int' }, cyclic = true }),
        const({ elements = { 'leader', 'localleader' }, cyclic = true }),
        const({ elements = { 'chore', 'feat' }, cyclic = true }),
        const({ elements = { 'double', 'single' }, cyclic = true }),
        const({ elements = { 'config', 'opts' }, cyclic = true }),
        const({ elements = { 'pre', 'post' }, cyclic = true }),
        const({ elements = { 'column', 'row' }, cyclic = true }),
        const({ elements = { 'before', 'after' }, cyclic = true }),
        const({ elements = { 'end', 'start' }, cyclic = true }),
        const({ elements = { 'high', 'low' }, cyclic = true }),
        const({ elements = { 'open', 'close' }, cyclic = true }),
        const({ elements = { 'and', 'or' }, cyclic = true }),
        const({ elements = { 'GET', 'POST' }, cyclic = true }),
      }
    end,
  },
}
