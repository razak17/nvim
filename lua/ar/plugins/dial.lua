local coding = ar.plugins.coding

---@param increment boolean
---@param g? boolean
local function dial(increment, g, group)
  local mode = vim.fn.mode(true)
  -- Use visual commands for VISUAL 'v', VISUAL LINE 'V' and VISUAL BLOCK '\22'
  local is_visual = mode == 'v' or mode == 'V' or mode == '\22'
  local func = (increment and 'inc' or 'dec')
    .. (g and '_g' or '_')
    .. (is_visual and 'visual' or 'normal')
  group = group or vim.g.dials_by_ft[vim.bo.filetype] or 'default'
  return require('dial.map')[func](group)
end

local function toggler()
  local augend = require('dial.augend')
  return {
    augend.constant.new({ elements = { '===', '!==' }, word = false }),
    augend.constant.new({ elements = { '==', '!=' }, word = false }),
    augend.constant.new({ elements = { 'new', 'old' } }),
    augend.constant.new({ elements = { 'yes', 'no' } }),
    augend.constant.new({ elements = { 'on', 'off' } }),
    augend.constant.new({ elements = { 'left', 'right' } }),
    augend.constant.new({ elements = { 'up', 'down' } }),
    augend.constant.new({ elements = { 'enable', 'disable' } }),
    augend.constant.new({ elements = { 'vim', 'emacs' } }),
    augend.constant.new({ elements = { 'margin', 'padding' } }),
    augend.constant.new({ elements = { '-', '+' } }),
    augend.constant.new({ elements = { 'onClick', 'onSubmit' } }),
    augend.constant.new({ elements = { 'public', 'private' } }),
    augend.constant.new({ elements = { 'string', 'int' } }),
    augend.constant.new({ elements = { 'leader', 'localleader' } }),
    augend.constant.new({ elements = { 'chore', 'feat' } }),
    augend.constant.new({ elements = { 'double', 'single' } }),
    augend.constant.new({ elements = { 'config', 'opts' } }),
    augend.constant.new({ elements = { 'pre', 'post' } }),
    augend.constant.new({ elements = { 'column', 'row' } }),
    augend.constant.new({ elements = { 'before', 'after' } }),
    augend.constant.new({ elements = { 'end', 'start' } }),
    augend.constant.new({ elements = { 'high', 'low' } }),
    augend.constant.new({ elements = { 'open', 'close' } }),
    augend.constant.new({ elements = { 'and', 'or' } }),
    augend.constant.new({ elements = { 'fill', 'outline' } }),
    augend.constant.new({ elements = { 'GET', 'POST', 'PUT', 'PATCH' } }),
    augend.constant.new({ elements = { 'TODO', 'FIXME' } }),
  }
end

return {
  {
    'ruicsh/tailwindcss-dial.nvim',
    cond = function()
      return ar.get_plugin_cond('tailwindcss-dial.nvim', coding)
    end,
  },
  {
    desc = 'Increment and decrement numbers, dates, and more',
    'monaqa/dial.nvim',
    cond = function() return ar.get_plugin_cond('dial.nvim', coding) end,
    -- stylua: ignore
    keys = {
      { '<C-a>', function() return dial(true) end, expr = true, desc = 'dial: increment', mode = { 'n', 'v' } },
      { '<C-x>', function() return dial(false) end, expr = true, desc = 'dial: decrement', mode = { 'n', 'v' } },
      { 'g<C-a>', function() return dial(true, true) end, expr = true, desc = 'dial: increment', mode = { 'n', 'x' } },
      { 'g<C-x>',function() return dial(false, true) end, expr = true, desc = 'dial: decrement', mode = { 'n', 'x' } },
      { '<leader>ii', function() return dial(true, false, 'toggler') end, expr = true, desc = 'dial: toggles' },
      { '<leader>ik', function() return dial(true, false, 'case') end, expr = true, desc = 'dial: case' },
    },
    opts = function()
      local augend = require('dial.augend')

      local logical_alias = augend.constant.new({
        elements = { '&&', '||' },
        word = false,
      })

      local cardinal_numbers = augend.constant.new({
        elements = {
          'one',
          'two',
          'three',
          'four',
          'five',
          'six',
          'seven',
          'eight',
          'nine',
          'ten',
        },
        word = false,
      })

      local ordinal_numbers = augend.constant.new({
        elements = {
          'first',
          'second',
          'third',
          'fourth',
          'fifth',
          'sixth',
          'seventh',
          'eighth',
          'ninth',
          'tenth',
        },
        word = false,
      })

      local months = augend.constant.new({
        elements = {
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        },
      })

      local default = {
        augend.integer.alias.decimal,
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.integer.alias.binary,
        augend.date.alias['%Y/%m/%d'],
        augend.date.alias['%Y-%m-%d'],
        augend.date.alias['%H:%M:%S'],
        augend.date.alias['%-m/%-d'],
        augend.constant.alias.de_weekday,
        augend.constant.alias.de_weekday_full,
        augend.constant.alias.en_weekday,
        augend.constant.alias.en_weekday_full,
        augend.constant.alias.bool,
        augend.constant.alias.Bool,
        cardinal_numbers,
        ordinal_numbers,
        months,
        logical_alias,
        unpack(toggler()),
      }

      local css = {
        augend.hexcolor.new({ case = 'lower' }),
        augend.hexcolor.new({ case = 'upper' }),
      }

      local lua = {
        augend.constant.new({ elements = { '==', '~=' }, word = false }),
        augend.constant.new({ elements = { 'api', 'fn' } }),
        augend.constant.new({
          elements = { 'cond', 'event', 'init', 'config', 'opts' },
        }),
      }

      if ar.lsp.enable then
        ar.list_insert(lua, { require('ar.enum_dial').augend() })
      end

      local ts = {
        augend.constant.new({ elements = { '&&', '||' }, word = false }),
        augend.constant.new({
          elements = { 'const', 'let', 'var', 'function' },
        }),
        augend.constant.new({ elements = { 'push', 'pop' } }),
        augend.constant.new({ elements = { 'import', 'export' } }),
        augend.constant.new({ elements = { 'interface', 'type' } }),
        augend.constant.new({ elements = { 'null', 'undefined' } }),
        augend.constant.new({ elements = { 'log', 'warn', 'error' } }),
        augend.constant.new({ elements = { 'string', 'number', 'boolean' } }),
        augend.constant.new({
          elements = { 'useState', 'useEffect', 'useCallback' },
        }),
      }

      local tsx = { unpack(ts), unpack(css) }

      if ar.has('tailwindcss-dial.nvim') then
        ar.list_insert(tsx, require('tailwindcss-dial').augends())
      end

      return {
        dials_by_ft = {
          css = 'css',
          javascript = 'ts',
          typescript = 'ts',
          typescriptreact = 'tsx',
          javascriptreact = 'tsx',
          astro = 'tsx',
          svelte = 'tsx',
          vue = 'tsx',
          json = 'json',
          lua = 'lua',
          markdown = 'md',
          sass = 'css',
          scss = 'css',
        },
        groups = {
          default = default,
          toggler = toggler(),
          case = {
            augend.case.new({
              types = {
                'camelCase',
                'snake_case',
                'PascalCase',
                'SCREAMING_SNAKE_CASE',
              },
            }),
          },
          go = {
            augend.constant.new({ elements = { '&&', '||' }, word = false }),
            augend.constant.new({ elements = { 'string', 'int', 'bool' } }),
          },
          lua = lua,
          md = {
            augend.misc.alias.markdown_header,
            augend.constant.new({ elements = { '[ ]', '[x]' }, word = false }),
            augend.misc.alias.markdown_header,
          },
          ts = ts,
          tsx = tsx,
          css = css,
          json = {
            augend.semver.alias.semver, -- versioning (v1.1.2)
          },
        },
      }
    end,
    config = function(_, opts)
      -- copy defaults to each group
      for name, group in pairs(opts.groups) do
        if name ~= 'default' then ar.list_insert(group, opts.groups.default) end
      end
      require('dial.config').augends:register_group(opts.groups)
      vim.g.dials_by_ft = opts.dials_by_ft
    end,
  },
}
