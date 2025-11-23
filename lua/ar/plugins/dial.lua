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
      local const_new = augend.constant.new

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
        const_new({ elements = { 'true', 'false' }, cyclic = true }),
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

      local toggler = {
        const_new({ elements = { '==', '~=' }, cyclic = true }),
        const_new({ elements = { '===', '!==' }, cyclic = true }),
        const_new({ elements = { '!=', '==' }, cyclic = true }),
        const_new({ elements = { 'true', 'false' }, cyclic = true }),
        const_new({ elements = { 'True', 'False' }, cyclic = true }),
        const_new({ elements = { 'new', 'old' }, cyclic = true }),
        const_new({ elements = { 'yes', 'no' }, cyclic = true }),
        const_new({ elements = { 'on', 'off' }, cyclic = true }),
        const_new({ elements = { 'left', 'right' }, cyclic = true }),
        const_new({ elements = { 'up', 'down' }, cyclic = true }),
        const_new({ elements = { 'enable', 'disable' }, cyclic = true }),
        const_new({ elements = { 'vim', 'emacs' }, cyclic = true }),
        const_new({ elements = { 'let', 'const' }, cyclic = true }),
        const_new({ elements = { 'margin', 'padding' }, cyclic = true }),
        const_new({ elements = { '-', '+' }, cyclic = true }),
        const_new({ elements = { 'onClick', 'onSubmit' }, cyclic = true }),
        const_new({ elements = { 'public', 'private' }, cyclic = true }),
        const_new({ elements = { 'string', 'int' }, cyclic = true }),
        const_new({ elements = { 'leader', 'localleader' }, cyclic = true }),
        const_new({ elements = { 'chore', 'feat' }, cyclic = true }),
        const_new({ elements = { 'double', 'single' }, cyclic = true }),
        const_new({ elements = { 'config', 'opts' }, cyclic = true }),
        const_new({ elements = { 'pre', 'post' }, cyclic = true }),
        const_new({ elements = { 'column', 'row' }, cyclic = true }),
        const_new({ elements = { 'before', 'after' }, cyclic = true }),
        const_new({ elements = { 'end', 'start' }, cyclic = true }),
        const_new({ elements = { 'high', 'low' }, cyclic = true }),
        const_new({ elements = { 'open', 'close' }, cyclic = true }),
        const_new({ elements = { 'and', 'or' }, cyclic = true }),
        const_new({ elements = { 'GET', 'POST' }, cyclic = true }),
      }

      ar.list_insert(default, toggler)

      config.augends:register_group({
        default = default,
        toggler = toggler,
      })

      config.augends:on_filetype({
        go = vim
          .iter({
            default,
            {
              const_new({
                elements = { '&&', '||' },
                word = false,
                cyclic = true,
              }),
            },
          })
          :flatten()
          :totable(),
      })

      config.augends:on_filetype({
        markdown = vim
          .iter({ default, { augend.misc.alias.markdown_header } })
          :flatten()
          :totable(),
      })

      local bool = const_new({ elements = { 'True', 'False' }, cyclic = true })

      config.augends:on_filetype({
        python = vim.iter({ default, { bool } }):flatten():totable(),
      })

      config.augends:on_filetype({
        lua = vim
          .iter({
            default,
            {
              const_new({ elements = { '==', '~=' }, cyclic = true }),
            },
          })
          :flatten()
          :totable(),
      })

      local ts = vim
        .iter({
          default,
          {
            augend.integer.alias.decimal,
            augend.integer.alias.hex,
            augend.paren.alias.quote,
            const_new({ elements = { 'let', 'const' } }),
            const_new({ elements = { '!=', '==' }, cyclic = true }),
            const_new({ elements = { '===', '!==' }, cyclic = true }),
            const_new({ elements = { 'onClick', 'onSubmit' }, cyclic = true }),
            const_new({ elements = { 'import', 'export' }, cyclic = true }),
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
