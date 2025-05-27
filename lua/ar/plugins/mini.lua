local api, fn = vim.api, vim.fn
local separators = ar.ui.icons.separators
local minimal = ar.plugins.minimal

-- https://www.lazyvim.org/plugins/coding#miniai
-- Mini.ai indent text object
-- For "a", it will include the non-whitespace line surrounding the indent block.
-- "a" is line-wise, "i" is character-wise.
local function ai_indent(ai_type)
  local spaces = (' '):rep(vim.o.tabstop)
  local lines = api.nvim_buf_get_lines(0, 0, -1, false)
  local indents = {} ---@type {line: number, indent: number, text: string}[]

  for l, line in ipairs(lines) do
    if not line:find('^%s*$') then
      indents[#indents + 1] = {
        line = l,
        indent = #line:gsub('\t', spaces):match('^%s*'),
        text = line,
      }
    end
  end

  local ret = {}

  for i = 1, #indents do
    if i == 1 or indents[i - 1].indent < indents[i].indent then
      local from, to = i, i
      for j = i + 1, #indents do
        if indents[j].indent < indents[i].indent then break end
        to = j
      end
      from = ai_type == 'a' and from > 1 and from - 1 or from
      to = ai_type == 'a' and to < #indents and to + 1 or to
      ret[#ret + 1] = {
        indent = indents[i].indent,
        from = {
          line = indents[from].line,
          col = ai_type == 'a' and 1 or indents[from].indent + 1,
        },
        to = { line = indents[to].line, col = #indents[to].text },
      }
    end
  end

  return ret
end

-- taken from MiniExtra.gen_ai_spec.buffer
local function ai_buffer(ai_type)
  local start_line, end_line = 1, fn.line('$')
  if ai_type == 'i' then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank =
      fn.nextnonblank(start_line), fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(fn.getline(end_line):len(), 1)
  return {
    from = { line = start_line, col = 1 },
    to = { line = end_line, col = to_col },
  }
end

return {
  {
    'echasnovski/mini.extra',
    config = function() require('mini.extra').setup() end,
  },
  {
    'echasnovski/mini.hipatterns',
    cond = function()
      if ar.plugin_disabled('mini.hipatterns') then return false end
      return (
        io.open(fn.expand('%:p:h') .. '/.lazy.lua', 'r') ~= nil and not minimal
      ) or minimal
    end,
    event = { 'BufRead', 'BufNewFile' },
    opts = function()
      local hipatterns = require('mini.hipatterns')
      local opts = {}
      if minimal then
        opts = vim.tbl_extend('force', opts, {
          highlighters = {
            fixme = {
              pattern = '%f[%w]()FIXME()%f[%W]',
              group = 'MiniHipatternsFixme',
            },
            hack = {
              pattern = '%f[%w]()HACK()%f[%W]',
              group = 'MiniHipatternsHack',
            },
            todo = {
              pattern = '%f[%w]()TODO()%f[%W]',
              group = 'MiniHipatternsTodo',
            },
            note = {
              pattern = '%f[%w]()NOTE()%f[%W]',
              group = 'MiniHipatternsNote',
            },
            hex_color = hipatterns.gen_highlighter.hex_color(),
          },
        })
      end
      return opts
    end,
  },
  {
    'echasnovski/mini.icons',
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
    opts = {
      file = {
        ['init.lua'] = { glyph = '󰢱', hl = 'MiniIconsAzure' }, -- disable nvim glyph: https://github.com/echasnovski/mini.nvim/issues/1384
        ['README.md'] = { glyph = '' },
        ['.ignore'] = { glyph = '󰈉', hl = 'MiniIconsGrey' },
        ['pre-commit'] = { glyph = '󰊢' },
      },
      extension = {
        ['d.ts'] = { hl = 'MiniIconsRed' }, -- distinguish `.d.ts` from `.ts`
        ['applescript'] = { glyph = '󰀵', hl = 'MiniIconsGrey' },
        ['log'] = { glyph = '󱂅', hl = 'MiniIconsGrey' },
        ['gitignore'] = { glyph = '' },
      },
      filetype = {
        ['css'] = { glyph = '', hl = 'MiniIconsRed' },
        ['typescript'] = { hl = 'MiniIconsCyan' },
        ['vim'] = { glyph = '' }, -- used for `obsidian.vimrc`

        -- plugin-filetypes
        ['snacks_input'] = { glyph = '󰏫' },
        ['snacks_notif'] = { glyph = '󰎟' },
        ['noice'] = { glyph = '󰎟' },
        ['mason'] = { glyph = '' },
        ['ccc-ui'] = { glyph = '' },
        ['scissors-snippet'] = { glyph = '󰩫' },
        ['rip-substitute'] = { glyph = '' },
      },
      config = function(_, opts)
        require('mini.icons').setup(opts)
        -- plugin still needing the devicons mock: telescope
        require('mini.icons').mock_nvim_web_devicons()
      end,
    },
  },
  {
    'echasnovski/mini.indentscope',
    cond = function()
      local indentline_enable = ar_config.ui.indentline.enable
      local indentline_variant = ar_config.ui.indentline.variant
      return not minimal
        and indentline_enable
        and indentline_variant == 'mini.indentscope'
    end,
    event = 'UIEnter',
    opts = {
      symbol = separators.left_thin_block,
      draw = {
        delay = 100,
        priority = 2,
        animation = function(s, n) return s / n * 20 end,
      },
      -- stylua: ignore
      filetype_exclude = {
        'lazy', 'fzf', 'alpha', 'dbout', 'neo-tree-popup', 'log', 'gitcommit',
        'txt', 'help', 'NvimTree', 'git', 'flutterToolsOutline', 'undotree',
        'markdown', 'norg', 'org', 'orgagenda', 'snacks_dashboard',
        '', -- for all buffers without a file type
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('mini-indentscope', {
        theme = {
          ['onedark'] = {
            { MiniIndentscopeSymbol = { link = 'IndentBlanklineContextChar' } },
            { MiniIndentscopeSymbolOff = { link = 'IndentBlanklineChar' } },
          },
          ['default'] = {
            { MiniIndentscopeSymbol = { link = 'NonText' } },
            { MiniIndentscopeSymbolOff = { link = 'NonText' } },
          },
        },
      })
      require('mini.indentscope').setup(opts)
    end,
  },
  {
    'echasnovski/mini.misc',
    cond = false,
    init = function()
      ar.add_to_select_menu(
        'toggle',
        { ['Toggle Zoom'] = 'lua require("mini.misc").zoom()' }
      )
    end,
    opts = {},
  },
  {
    'echasnovski/mini.bracketed',
    cond = not ar.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'echasnovski/mini.trailspace',
    -- stylua: ignore
    keys = {
      { '<leader>wx', '<Cmd>lua MiniTrailspace.trim()<CR>', desc = 'trailspace: trim all', },
      { '<leader>wl', '<Cmd>lua MiniTrailspace.trim_last_lines()<CR>', desc = 'trailspace: trim last lines', },
    },
    opts = {},
  },
  {
    'echasnovski/mini.cursorword',
    cond = false,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'echasnovski/mini.ai',
    cond = not minimal,
    event = { 'VeryLazy' },
    config = function()
      -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/mini.lua?plain=1#L64
      local objects = {
        { ' ', desc = 'whitespace' },
        { '"', desc = '" string' },
        { "'", desc = "' string" },
        { '(', desc = '() block' },
        { ')', desc = '() block with ws' },
        { '<', desc = '<> block' },
        { '>', desc = '<> block with ws' },
        { '?', desc = 'user prompt' },
        { 'U', desc = 'use/call without dot' },
        { '[', desc = '[] block' },
        { ']', desc = '[] block with ws' },
        { '_', desc = 'underscore' },
        { '`', desc = '` string' },
        { 'a', desc = 'argument' },
        { 'b', desc = ')]} block' },
        { 'c', desc = 'class' },
        { 'd', desc = 'digit(s)' },
        { 'e', desc = 'CamelCase / snake_case' },
        { 'f', desc = 'function' },
        { 'g', desc = 'entire file' },
        { 'i', desc = 'indent' },
        { 'o', desc = 'block, conditional, loop' },
        { 'q', desc = 'quote `"\'' },
        { 't', desc = 'tag' },
        { 'u', desc = 'use/call' },
        { '{', desc = '{} block' },
        { '}', desc = '{} with ws' },
      }

      local ret = { mode = { 'o', 'x' } }
      for prefix, name in pairs({
        i = 'inside',
        a = 'around',
        il = 'last',
        ['in'] = 'next',
        al = 'last',
        an = 'next',
      }) do
        ret[#ret + 1] = { prefix, group = name }
        for _, obj in ipairs(objects) do
          local desc = obj.desc
          if prefix:sub(1, 1) == 'i' then desc = desc:gsub(' with ws', '') end
          ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
        end
      end

      if ar.is_available('which-key.nvim') then
        require('which-key').add(ret, { notify = false })
      end

      local ai = require('mini.ai')
      local gen_ai_spec = require('mini.extra').gen_ai_spec

      require('mini.ai').setup({
        n_lines = 500,
        custom_textobjects = {
          B = gen_ai_spec.buffer(),
          D = gen_ai_spec.diagnostic(),
          I = gen_ai_spec.indent(),
          L = gen_ai_spec.line(),
          N = gen_ai_spec.number(),
          o = ai.gen_spec.treesitter({ -- code block
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }),
          f = ai.gen_spec.treesitter({
            a = '@function.outer',
            i = '@function.inner',
          }), -- function
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }), -- class
          t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
          d = { '%f[%d]%d+' }, -- digits
          e = { -- Word with case
            {
              '%u[%l%d]+%f[^%l%d]',
              '%f[%S][%l%d]+%f[^%l%d]',
              '%f[%P][%l%d]+%f[^%l%d]',
              '^[%l%d]+%f[^%l%d]',
            },
            '^().*()$',
          },
          i = ai_indent, -- indent
          g = ai_buffer, -- buffer
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = '[%w_]' }), -- without dot in function name
        },
        mappings = { around_last = '', inside_last = '' },
      })
    end,
    dependencies = { 'echasnovski/mini.extra' },
  },
  {
    'echasnovski/mini.surround',
    keys = function(_, keys)
      -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/coding/mini-surround.lua#L9
      local opts = ar.opts('mini.surround')
      local mappings = {
        { opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
        { opts.mappings.delete, desc = 'Delete Surrounding' },
        { opts.mappings.find, desc = 'Find Right Surrounding' },
        { opts.mappings.find_left, desc = 'Find Left Surrounding' },
        { opts.mappings.highlight, desc = 'Highlight Surrounding' },
        { opts.mappings.replace, desc = 'Replace Surrounding' },
        {
          opts.mappings.update_n_lines,
          desc = 'Update `MiniSurround.config.n_lines`',
        },
      }
      mappings = vim.tbl_filter(
        function(m) return m[1] and #m[1] > 0 end,
        mappings
      )
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
      },
    },
    init = function()
      -- https://www.reddit.com/r/neovim/comments/1fddxak/can_figure_out_how_to_turn_a_large_motion_into/
      ar.command('AddSurroundingTag', function()
        vim.cmd('normal vat')
        vim.schedule(function() vim.cmd('normal gsat') end)
      end, { desc = 'add surround HTML tag' })

      ar.add_to_select_menu(
        'command_palette',
        { ['Add surround HTML tag'] = 'AddSurroundingTag' }
      )
    end,
  },
  {
    'echasnovski/mini.completion',
    cond = minimal or ar_config.completion.variant == 'mini.completion',
    event = { 'InsertEnter', 'BufEnter' },
    opts = {},
    config = function(_, opts)
      require('mini.completion').setup(opts)

      ar.augroup('MiniCompletionDisable', {
        event = { 'FileType' },
        desc = 'Disable completion for certain files',
        command = function()
          local ignored_filetypes = {
            'TelescopePrompt',
            'minifiles',
            'snacks_picker_input',
          }
          if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
            vim.b.minicompletion_disable = true
          end
        end,
      })
    end,
  },
  {
    'echasnovski/mini.splitjoin',
    keys = { { '<leader>J', desc = 'splitjoin: toggle' } },
    opts = { mappings = { toggle = '<leader>J' } },
  },
  {
    'echasnovski/mini.diff',
    event = { 'BufRead', 'BufNewFile' },
    cond = false,
    opts = {},
  },
  {
    'echasnovski/mini.pairs',
    cond = minimal and not ar.plugin_disabled('mini.pairs'),
    event = 'VeryLazy',
    init = function()
      local function toggle_minipairs()
        if not ar.plugin_available('mini.pairs') then return end
        vim.g.minipairs_disable = not vim.g.minipairs_disable
        if vim.g.minipairs_disable then
          vim.notify('Disabled auto pairs', 'warn', { title = 'Option' })
        else
          vim.notify('Enabled auto pairs', 'info', { title = 'Option' })
        end
      end

      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle Minipairs'] = toggle_minipairs }
      )
    end,
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { 'string' },
      skip_unbalanced = true,
      markdown = true,
      mappings = {
        ['`'] = {
          action = 'closeopen',
          pair = '``',
          neigh_pattern = '[^\\`].',
          register = { cr = false },
        },
      },
    },
  },
  {
    'echasnovski/mini.comment',
    cond = not ar.plugin_disabled('mini.comment'),
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          if ar.is_available('nvim-ts-context-commentstring') then
            return require('ts_context_commentstring.internal').calculate_commentstring()
          end
          return vim.bo.commentstring
        end,
      },
    },
  },
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'echasnovski/mini.animate',
    cond = function()
      return not minimal and ar_config.animation.enable and vim.g.neovide == nil
    end,
    event = 'VeryLazy',
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Mini Animate'] = function()
          vim.g.minianimate_disable = not vim.g.minianimate_disable
          vim.notify(
            'Mini Animate '
              .. (vim.g.minianimate_disable and 'disabled' or 'enabled'),
            'info',
            { title = 'Toggle' }
          )
        end,
      })
    end,
    opts = function(_, opts)
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs({ 'Up', 'Down' }) do
        local key = '<ScrollWheel' .. scroll .. '>'
        vim.keymap.set({ '', 'i' }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'grug-far',
        callback = function() vim.b.minianimate_disable = true end,
      })

      local animate = require('mini.animate')
      return vim.tbl_deep_extend('force', opts, {
        resize = {
          timing = animate.gen_timing.linear({ duration = 50, unit = 'total' }),
        },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 150, unit = 'total' }),
          subscroll = animate.gen_subscroll.equal({
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          }),
        },
      })
    end,
  },
  {
    'echasnovski/mini.move',
    enabled = false,
    cond = not minimal and false,
    event = 'VeryLazy',
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = '<M-h>',
        right = '<M-l>',
        down = '<M-j>',
        up = '<M-k>',
        -- Move current line in Normal mode
        line_left = '<M-h>',
        line_right = '<M-/>',
        line_down = '<M-j>',
        line_up = '<M-k>',
      },
    },
  },
}
