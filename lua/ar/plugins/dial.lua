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
    'ruicsh/tailwindcss-dial.nvim',
    cond = function()
      return ar.get_plugin_cond('tailwindcss-dial.nvim', coding)
    end,
  },
  {
    'monaqa/dial.nvim',
    cond = function() return ar.get_plugin_cond('dial.nvim', coding) end,
    init = function()
      ---@param group string
      ---@param args integer
      local function on_filetype(group, buf)
        map('n', '<C-a>', inc('normal', group), { buffer = buf })
        map('n', '<C-x>', dec('normal', group), { buffer = buf })
      end

      ar.augroup('DialForFts', {
        event = { 'FileType' },
        pattern = { 'go' },
        command = function(arg) on_filetype('go', arg.buf) end,
      }, {
        event = { 'FileType' },
        pattern = { 'lua' },
        command = function(arg) on_filetype('lua', arg.buf) end,
      }, {
        event = { 'FileType' },
        pattern = { 'markdown' },
        command = function(arg) on_filetype('md', arg.buf) end,
      }, {
        event = { 'FileType' },
        pattern = {
          'typescript',
          'javascript',
          'typescriptreact',
          'javascriptreact',
          'tsx',
          'jsx',
          'svelte',
          'vue',
          'astro',
        },
        command = function(arg) on_filetype('ts', arg.buf) end,
      })
    end,
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
      { '<leader>ik', inc('normal', 'case'), desc = 'dial: case' },
    },
    config = function()
      local augend = require('dial.augend')
      local config = require('dial.config')
      local dconst = augend.constant.new

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
      }

      local case = {
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
        dconst({ elements = { '===', '!==' }, word = false }),
        dconst({ elements = { '==', '!=' }, word = false }),
        dconst({ elements = { 'true', 'false' } }),
        dconst({ elements = { 'True', 'False' } }),
        dconst({ elements = { 'new', 'old' } }),
        dconst({ elements = { 'yes', 'no' } }),
        dconst({ elements = { 'on', 'off' } }),
        dconst({ elements = { 'left', 'right' } }),
        dconst({ elements = { 'up', 'down' } }),
        dconst({ elements = { 'enable', 'disable' } }),
        dconst({ elements = { 'vim', 'emacs' } }),
        dconst({ elements = { 'margin', 'padding' } }),
        dconst({ elements = { '-', '+' } }),
        dconst({ elements = { 'onClick', 'onSubmit' } }),
        dconst({ elements = { 'public', 'private' } }),
        dconst({ elements = { 'string', 'int' } }),
        dconst({ elements = { 'leader', 'localleader' } }),
        dconst({ elements = { 'chore', 'feat' } }),
        dconst({ elements = { 'double', 'single' } }),
        dconst({ elements = { 'config', 'opts' } }),
        dconst({ elements = { 'pre', 'post' } }),
        dconst({ elements = { 'column', 'row' } }),
        dconst({ elements = { 'before', 'after' } }),
        dconst({ elements = { 'end', 'start' } }),
        dconst({ elements = { 'high', 'low' } }),
        dconst({ elements = { 'open', 'close' } }),
        dconst({ elements = { 'and', 'or' } }),
        dconst({ elements = { 'GET', 'POST' } }),
      }

      ar.list_insert(default, toggler)

      local go = {
        dconst({ elements = { '&&', '||' }, word = false }),
        dconst({ elements = { 'string', 'int', 'bool' } }),
        unpack(default),
      }

      local md = { unpack(default), augend.misc.alias.markdown_header }

      local lua = {
        unpack(default),
        dconst({ elements = { '==', '~=' }, word = false }),
        dconst({ elements = { 'api', 'fn' } }),
        dconst({ elements = { 'cond', 'event', 'init', 'config', 'opts' } }),
      }

      if ar.lsp.enable then
        local enum_dial = require('ar.enum_dial')
        ar.list_insert(lua, { enum_dial.augend() })
      end

      local ts = {
        unpack(default),
        dconst({ elements = { '&&', '||' }, word = false }),
        dconst({ elements = { 'const', 'let', 'var', 'function' } }),
        dconst({ elements = { 'import', 'export' } }),
        dconst({ elements = { 'interface', 'type' } }),
        dconst({ elements = { 'null', 'undefined' } }),
        dconst({ elements = { 'string', 'number', 'boolean' } }),
        dconst({ elements = { 'useState', 'useEffect', 'useCallback' } }),
        augend.paren.alias.quote,
      }

      if ar.has('tailwindcss-dial.nvim') then
        local tailwindcss_dial = require('tailwindcss-dial')
        ar.list_insert(ts, { unpack(tailwindcss_dial.augends()) })
      end

      config.augends:register_group({
        default = default,
        toggler = toggler,
        case = case,
        lua = lua,
        go = go,
        md = md,
        ts = ts,
      })
    end,
  },
}
