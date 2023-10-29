local api = vim.api
local ui, highlight = rvim.ui, rvim.highlight
local icons, codicons = ui.icons, ui.codicons
local border, separators = ui.current.border, ui.icons.separators

return {
  {
    'Aasim-A/scrollEOF.nvim',
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'tomiis4/BufferTabs.nvim',
    cond = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    keys = {
      {
        '<leader>ob',
        '<Cmd>BufferTabsToggle<CR>',
        desc = 'buffer-tabs: toggle',
      },
    },
    config = function()
      require('buffertabs').setup({
        border = 'single',
        horizontal = 'right',
        hl_group = 'BufferTabs',
        hl_group_inactive = 'Dim',
      })
      require('buffertabs').toggle()
    end,
  },
  {
    'itchyny/vim-highlighturl',
    event = 'ColorScheme',
    config = function() vim.g.highlighturl_guifg = highlight.get('URL', 'fg') end,
  },
  {
    'lukas-reineke/virt-column.nvim',
    cond = not rvim.plugins.minimal and false,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      char = separators.right_thin_block,
      highlight = 'IndentBlanklineContextChar',
    },
  },
  {
    'razak17/smartcolumn.nvim',
    cond = not rvim.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      colorcolumn = '0',
      custom_autocommand = true,
    },
  },
  {
    'utilyre/sentiment.nvim',
    cond = not rvim.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      excluded_filetypes = {
        [''] = true,
      },
    },
  },
  {
    'aaron-p1/match-visual.nvim',
    cond = not rvim.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'tzachar/local-highlight.nvim',
    cond = not rvim.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = { hlgroup = 'Search' },
  },
  {
    'whatyouhide/vim-lengthmatters',
    cond = false,
    lazy = false,
    config = function()
      vim.g.lengthmatters_highlight_one_column = 1
      vim.g.lengthmatters_excluded = { 'packer' }
      vim.g.lengthmatters_linked_to = 'WhichKeyGroup'
    end,
  },
  {
    'laytan/cloak.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'folke/twilight.nvim',
    cond = rvim.treesitter.enable,
    cmd = 'Twilight',
    opts = {
      context = 40,
      dimming = { alpha = 0.45, inactive = true },
      exclude = { 'alpha', 'git' },
    },
  },
  {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    opts = {
      window = { width = 90 },
      plugins = {
        kitty = { enabled = true, font = '+0' },
        tmux = { enabled = true },
      },
    },
  },
  {
    'lewis6991/whatthejump.nvim',
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      map('n', '<M-k>', function()
        require('whatthejump').show_jumps(false)
        return '<C-o>'
      end, { expr = true })

      map('n', '<M-j>', function()
        require('whatthejump').show_jumps(true)
        return '<C-i>'
      end, { expr = true })
    end,
  },
  {
    'eandrju/cellular-automaton.nvim',
    cmd = 'CellularAutomaton',
    keys = {
      {
        '<localleader>ag',
        '<Cmd>CellularAutomaton game_of_life<CR>',
        desc = 'automaton: game of life',
      },
      {
        '<localleader>am',
        '<Cmd>CellularAutomaton make_it_rain<CR>',
        desc = 'automaton: make it rain',
      },
    },
  },
  {
    'tjdevries/sPoNGe-BoB.NvIm',
    keys = {
      {
        '<localleader>ab',
        '<cmd>SpOnGeBoBiFy<CR>',
        mode = { 'v' },
        desc = 'SpOnGeBoB: SpOnGeBoBiFy',
      },
    },
  },
  {
    'tamton-aquib/zone.nvim',
    cond = false,
    event = 'VeryLazy',
    opts = {
      style = 'epilepsy',
      exclude_filetypes = {
        'NeogitStatus',
        'NeogitCommitMessage',
      },
    },
  },
  {
    'tamton-aquib/flirt.nvim',
    cond = false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'tzachar/highlight-undo.nvim',
    cond = not rvim.plugins.minimal,
    event = 'BufRead',
    opts = {
      undo = { hlgroup = 'Search' },
      redo = { hlgroup = 'Search' },
    },
  },
  {
    'yorickpeterse/nvim-pqf',
    event = 'BufRead',
    opts = {},
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {
      preview = {
        border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
      },
    },
  },
  {
    'kevinhwang91/nvim-hlslens',
    cond = not rvim.plugins.minimal,
    lazy = false,
    keys = {
      {
        'n',
        "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>",
      },
      {
        'N',
        "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>",
      },
      { '*', "*<Cmd>lua require('hlslens').start()<CR>" },
      { '#', "#<Cmd>lua require('hlslens').start()<CR>" },
    },
    config = function()
      highlight.plugin('nvim-hlslens', {
        { HlSearchNear = { fg = { from = 'WildMenu' }, bg = 'NONE' } },
        { HlSearchLens = { fg = { from = 'WildMenu' }, bg = 'NONE' } },
      })
      require('hlslens').setup({
        nearest_float_when = false,
        override_lens = function(render, posList, nearest, idx, relIdx)
          local sfw = vim.v.searchforward == 1
          local indicator, text, chunks
          local absRelIdx = math.abs(relIdx)
          if absRelIdx > 1 then
            indicator = ('%d%s'):format(
              absRelIdx,
              sfw ~= (relIdx > 1) and icons.misc.up or icons.misc.down
            )
          elseif absRelIdx == 1 then
            indicator = sfw ~= (relIdx == 1) and icons.misc.up
              or icons.misc.down
          else
            indicator = icons.misc.dot
          end
          local lnum, col = unpack(posList[idx])
          if nearest then
            local cnt = #posList
            if indicator ~= '' then
              text = ('[%s %d/%d]'):format(indicator, idx, cnt)
            else
              text = ('[%d/%d]'):format(idx, cnt)
            end
            chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLensNear' } }
          else
            text = ('[%s %d]'):format(indicator, idx)
            chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
          end
          render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
        end,
      })
    end,
  },
  {
    'stevearc/dressing.nvim',
    cond = not rvim.plugins.minimal,
    event = 'BufRead',
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.select(...)
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
          opts.prompt = opts.prompt and opts.prompt:gsub(':', '')
          if opts.kind == 'codeaction' then
            return {
              backend = 'fzf_lua',
              fzf_lua = rvim.fzf.cursor_dropdown({
                winopts = { title = opts.prompt },
              }),
            }
          end
          return {
            backend = 'fzf_lua',
            fzf_lua = rvim.fzf.dropdown({
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
  },
  {
    'folke/todo-comments.nvim',
    cond = rvim.treesitter.enable,
    event = 'BufReadPre',
    cmd = { 'TodoTelescope', 'TodoTrouble', 'TodoQuickFix', 'TodoDots' },
    keys = {
      { '<localleader>tt', '<cmd>TodoDots<CR>', desc = 'todo: dotfiles todos' },
      {
        '<localleader>tj',
        function() require('todo-comments').jump_next() end,
        desc = 'todo-comments: next todo',
      },
      {
        '<localleader>tk',
        function() require('todo-comments').jump_prev() end,
        desc = 'todo-comments: prev todo',
      },
    },
    config = function()
      require('todo-comments').setup({ highlight = { after = '' } })
      rvim.command(
        'TodoDots',
        string.format(
          'TodoTelescope cwd=%s keywords=TODO,FIXME',
          vim.fn.stdpath('config')
        )
      )
    end,
  },
  {
    'uga-rosa/ccc.nvim',
    cmd = { 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccPick' },
    opts = function()
      local ccc = require('ccc')
      local p = ccc.picker
      p.hex.pattern = {
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)>]=],
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)(\x\x)>]=],
      }
      ccc.setup({
        win_opts = { border = border },
        pickers = {
          p.hex,
          p.css_rgb,
          p.css_hsl,
          p.css_hwb,
          p.css_lab,
          p.css_lch,
          p.css_oklab,
          p.css_oklch,
        },
        highlighter = {
          auto_enable = true,
          excludes = {
            'dart',
            'lazy',
            'orgagenda',
            'org',
            'NeogitStatus',
            'toggleterm',
          },
        },
      })
    end,
  },
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufRead', 'BufNewFile' },
    cond = rvim.treesitter.enable,
    keys = {
      {
        '<leader>wp',
        function() require('dropbar.api').pick() end,
        desc = 'winbar: pick',
      },
    },
    config = function()
      require('dropbar').setup({
        general = {
          update_interval = 100,
          enable = function(buf, win)
            local b, w = vim.bo[buf], vim.wo[win]
            local decor =
              ui.decorations.get({ ft = b.ft, bt = b.bt, setting = 'winbar' })
            return decor
              and decor.ft ~= false
              and decor.bt ~= false
              and b.bt == ''
              and not w.diff
              and not api.nvim_win_get_config(win).zindex
              and api.nvim_buf_get_name(buf) ~= ''
          end,
        },
        icons = {
          ui = { bar = { separator = ' ' .. ui.icons.misc.triangle .. ' ' } },
          kinds = {
            symbols = vim.tbl_map(
              function(value) return value .. ' ' end,
              require('lspkind').symbol_map
            ),
          },
        },
        menu = {
          win_configs = {
            border = border,
            col = function(menu)
              return menu.prev_menu and menu.prev_menu._win_configs.width + 1
                or 0
            end,
          },
        },
      })
      highlight.plugin('dropbar', {
        theme = {
          ['onedark'] = {
            { DropBarIconUISeparator = { fg = { from = 'Label' } } },
            { DropBarIconUIIndicator = { link = 'Label' } },
            { DropBarMenuHoverEntry = { bg = 'NONE' } },
            { DropBarMenuCurrentContext = { link = 'CursorLine' } },
          },
        },
      })
    end,
  },
  {
    'shellRaining/hlchunk.nvim',
    cond = false,
    event = 'BufRead',
    config = function()
      require('hlchunk').setup({
        indent = {
          chars = { '▏' },
          style = {
            { fg = highlight.get('IndentBlanklineChar', 'fg') },
          },
        },
        blank = { enable = false },
        chunk = {
          chars = {
            horizontal_line = '─',
            vertical_line = '│',
            left_top = '┌',
            left_bottom = '└',
            right_arrow = '─',
          },
          style = highlight.tint(
            highlight.get('IndentBlanklineContextChar', 'fg'),
            -0.2
          ),
        },
        line_num = {
          style = highlight.get('CursorLineNr', 'fg'),
        },
      })
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    cond = rvim.treesitter.enable and false,
    event = 'UIEnter',
    main = 'ibl',
    opts = {
      indent = {
        char = separators.left_thin_block,
        tab_char = separators.left_thin_block,
        highlight = 'IndentBlanklineChar',
      },
      scope = {
        char = separators.left_thin_block,
        show_start = false,
        show_end = false,
        include = {
          node_type = {
            ['*'] = { '*' },
          },
        },
        highlight = { 'IndentBlanklineContextChar' },
      },
      exclude = {
        buftypes = { 'nofile', 'terminal' },
        filetypes = {
          'aerial',
          'alpha',
          'dbout',
          'flutterToolsOutline',
          'git',
          'gitcommit',
          'help',
          'lazy',
          'log',
          'markdown',
          'neogitstatus',
          'neo-tree',
          'neo-tree-popup',
          'norg',
          'org',
          'orgagenda',
          'startify',
          'txt',
          'Trouble',
          'undotree',
        },
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'kevinhwang91/nvim-ufo',
    cond = rvim.treesitter.enable and false,
    event = 'VeryLazy',
    config = function()
      highlight.plugin('ufo', {
        {
          Folded = {
            bold = false,
            italic = false,
            bg = { from = 'CursorLine', alter = -0.15 },
          },
        },
      })
    end,
    keys = {
      {
        'zR',
        function() require('ufo').openAllFolds() end,
        'ufo: open all folds',
      },
      {
        'zM',
        function() require('ufo').closeAllFolds() end,
        'ufo: close all folds',
      },
      {
        'zP',
        function() require('ufo').peekFoldedLinesUnderCursor() end,
        'ufo: preview fold',
      },
    },
    opts = function()
      local ft_map = { rust = 'lsp' }
      require('ufo').setup({
        open_fold_hl_timeout = 0,
        preview = {
          win_config = {
            border = rvim.ui.current.border,
            winhighlight = 'Normal:VertSplit,FloatBorder:VertSplit',
          },
        },
        enable_get_fold_virt_text = true,
        close_fold_kinds = { 'imports', 'comment' },
        provider_selector = function(_, ft)
          return ft_map[ft] or { 'treesitter', 'indent' }
        end,
      })
    end,
    dependencies = { 'kevinhwang91/promise-async' },
  },
  {
    'rcarriga/nvim-notify',
    event = 'BufRead',
    keys = {
      { '<leader>nn', '<cmd>Notifications<CR>', desc = 'notify: show' },
      {
        '<leader>nx',
        function() require('notify').dismiss({ silent = true, pending = true }) end,
        desc = 'notify: dismiss notifications',
      },
    },
    init = function()
      local notify = require('notify')
      notify.setup({
        max_width = function() return math.floor(vim.o.columns * 0.6) end,
        max_height = function() return math.floor(vim.o.lines * 0.8) end,
        background_colour = 'NormalFloat',
        on_open = function(win)
          if api.nvim_win_is_valid(win) then
            api.nvim_win_set_config(win, { border = ui.current.border })
          end
        end,
        top_down = false,
        timeout = 70,
        stages = 'fade_in_slide_out',
        render = function(...)
          local notif = select(2, ...)
          local style = notif.title[1] == '' and 'minimal' or 'default'
          require('notify.render')[style](...)
        end,
        icons = {
          ERROR = codicons.lsp.error,
          WARN = codicons.lsp.warn,
          INFO = codicons.lsp.info,
          HINT = codicons.lsp.hint,
          TRACE = codicons.lsp.trace,
        },
      })

      local ignored = {
        'No information available',
        '[LSP] Format request failed, no matching language servers.',
      }

      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(msg, level, opts)
        if vim.tbl_contains(ignored, msg) then return end
        return notify(msg, level, opts)
      end
    end,
  },
  {
    'LudoPinelli/comment-box.nvim',
    cond = not rvim.plugins.minimal,
    config = function(_, opts) require('comment-box').setup(opts) end,
    keys = {
      {
        '<leader><leader>bb',
        function() require('comment-box').ccbox() end,
        mode = { 'n', 'v' },
        desc = 'comment Box',
      },
      {
        '<leader><leader>be',
        function()
          local input = vim.fn.input('Catalog: ')
          require('comment-box').ccbox(input)
        end,
        mode = { 'n', 'v' },
        desc = 'Left comment box',
      },
      {
        '<leader><leader>bc',
        function() require('comment-box').lbox() end,
        mode = { 'n', 'v' },
        desc = 'left comment box',
      },
      {
        '<leader><leader>bx',
        function() require('comment-box').catalog() end,
        mode = { 'n', 'v' },
        desc = 'comment catalog',
      },
    },
    opts = {
      doc_width = 80,
      box_width = 60,
      borders = {
        top = '─',
        bottom = '─',
        left = '│',
        right = '│',
        top_left = '┌',
        top_right = '┐',
        bottom_left = '└',
        bottom_right = '┘',
      },
      line_width = 70,
      line = {
        line = '─',
        line_start = '─',
        line_end = '─',
      },
      outer_blank_lines = false, -- insert a blank line above and below the box
      inner_blank_lines = false, -- insert a blank line above and below the text
      line_blank_line_above = false, -- insert a blank line above the line
      line_blank_line_below = false, -- insert a blank line below the line
    },
  },
}
