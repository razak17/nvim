local ui, highlight = rvim.ui, rvim.highlight
local icons = ui.icons
local border, separators = ui.current.border, ui.icons.separators
local P = require('onedark.palette')

local minimal = rvim.plugins.minimal
local niceties = rvim.plugins.niceties

return {
  {
    'Aasim-A/scrollEOF.nvim',
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'karb94/neoscroll.nvim',
    cond = not minimal,
    event = 'BufRead',
    opts = {
      mappings = { '<C-d>', '<C-u>', '<C-y>', 'zt', 'zz', 'zb' },
      hide_cursor = true,
    },
  },
  {
    'tomiis4/BufferTabs.nvim',
    cond = not minimal and false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      { '<leader>ob', '<Cmd>BufferTabsToggle<CR>', desc = 'buffer-tabs: toggle', },
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
    cond = not minimal and false,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      char = separators.right_thin_block,
      highlight = 'IndentBlanklineContextChar',
    },
  },
  {
    'razak17/smartcolumn.nvim',
    cond = not minimal and niceties,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      disabled_filetypes = { 'quickfix' },
      colorcolumn = '0',
      custom_autocommand = true,
    },
  },
  {
    'utilyre/sentiment.nvim',
    cond = not minimal and niceties,
    init = function()
      -- `matchparen.vim` needs to be disabled manually in case of lazy loading
      vim.g.loaded_matchparen = 1
    end,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      excluded_filetypes = {
        [''] = true,
      },
    },
  },
  {
    'tummetott/reticle.nvim',
    event = 'VeryLazy',
    opts = {
      ignore = {
        cursorline = {
          'alpha',
          'DressingInput',
          'NvimSeparator',
          'TelescopePrompt',
          'toggleterm',
          'Trouble',
        },
        cursorcolumn = {},
      },
    },
  },
  {
    'HampusHauffman/block.nvim',
    cond = not minimal and niceties,
    cmd = { 'Block', 'BlockOn', 'BlockOff' },
    opts = {
      percent = 0.7,
      depth = 4,
      -- colors = {
      --   "red",
      --   "green",
      --   "yellow",
      -- },
    },
  },
  {
    'sindrets/winshift.nvim',
    cmd = { 'WinShift' },
    -- stylua: ignore
    keys = {
      { '<leader>sw', '<Cmd>WinShift<CR>', desc = 'winshift: start winshift mode', },
      { '<leader>ss', '<Cmd>WinShift swap<CR>', desc = 'winshift: swap two window', },
      { '<leader>sh', '<Cmd>WinShift left<CR>', desc = 'winshift: swap left' },
      { '<leader>sj', '<Cmd>WinShift down<CR>', desc = 'winshift: swap down' },
      { '<leader>sk', '<Cmd>WinShift up<CR>', desc = 'winshift: swap up' },
      { '<leader>sl', '<Cmd>WinShift right<CR>', desc = 'winshift: swap right', },
    },
    opts = {},
  },
  {
    'razak17/nvim-strict',
    cond = not rvim.plugins.minimal,
    event = { 'BufReadPost', 'BufNewFile' },
    -- stylua: ignore
    keys = {
      { '<localleader>sx', '<cmd>call clearmatches()<CR>', desc = 'strict: clear' },
      { '<localleader>sw', '<cmd>lua require("strict").remove_trailing_whitespace()<CR>', desc = 'strict: remove trailing whitespace' },
      { '<localleader>sl', '<cmd>lua require("strict").remove_trailing_empty_lines()<CR>', desc = 'strict: remove trailing empty lines' },
      { '<localleader>st', '<cmd>lua require("strict").convert_spaces_to_tabs()<CR>', desc = 'strict: convert spaces to tabs' },
      { '<localleader>ss', '<cmd>lua require("strict").convert_tabs_to_spaces()<CR>', desc = 'strict: convert tabs to spaces' },
      { '<localleader>sl', '<cmd>lua require("strict").split_overlong_lines()<CR>', desc = 'strict: split overlong lines' },
    },
    opts = {
      format_on_save = false,
      excluded_filetypes = { 'help' },
      excluded_buftypes = {
        'help',
        'nofile',
        'terminal',
        'prompt',
        'quickfix',
      },
      deep_nesting = {
        depth_limit = 4,
        ignored_trailing_characters = ',',
        ignored_leading_characters = '.',
      },
      overlong_lines = {
        length_limit = 100,
        split_on_save = false,
      },
      todos = { highlight = false },
    },
    config = function(_, opts) require('strict').setup(opts) end,
  },
  {
    'anuvyklack/windows.nvim',
    cond = not minimal and niceties,
    -- event = { 'BufReadPre', 'BufNewFile' },
    -- stylua: ignore
    keys = {
      { '<leader>wmh', '<Cmd>WindowsMaximizeHorizontally<CR>', desc = 'maximize horizontally' },
      { '<leader>wmv', '<Cmd>WindowsMaximizeVertically<CR>', desc = 'maximize vertically' },
      { '<leader>wmm', '<Cmd>WindowsMaximize<CR>', desc = 'maximize' },
      { '<leader>wm=', '<Cmd>WindowsEqualize<CR>', desc = 'equalize' },
      { '<leader>wmt', '<Cmd>WindowsToggleAutowidth<CR>', desc = 'toggle' },
      { "<leader>wmz", function() require("neo-zoom").neo_zoom({}) end, desc = "zoom window", },
    },
    opts = {},
    config = function(_, opts)
      require('neo-zoom').setup({})
      require('windows').setup(opts)
    end,
    dependencies = {
      'anuvyklack/middleclass',
      'nyngwang/NeoZoom.lua',
      'anuvyklack/animation.nvim',
    },
  },
  {
    'aaron-p1/match-visual.nvim',
    cond = not minimal and niceties,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'tzachar/local-highlight.nvim',
    cond = not minimal and niceties and not rvim.lsp.enable,
    event = { 'BufRead', 'BufNewFile' },
    opts = { hlgroup = 'Search' },
  },
  {
    'razak17/range-highlight.nvim',
    cond = not minimal and niceties,
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'winston0410/cmd-parser.nvim' },
    opts = {},
  },
  {
    'whatyouhide/vim-lengthmatters',
    cond = not minimal and false,
    lazy = false,
    config = function()
      vim.g.lengthmatters_highlight_one_column = 1
      vim.g.lengthmatters_excluded = { 'packer' }
      vim.g.lengthmatters_linked_to = 'WhichKeyGroup'
    end,
  },
  {
    'nvim-zh/colorful-winsep.nvim',
    cond = not minimal and niceties,
    event = { 'WinNew' },
    opts = {
      highlight = {
        bg = rvim.highlight.get('Normal', 'bg'),
        fg = P.cursor,
      },
    },
  },
  {
    'benlubas/wrapping-paper.nvim',
    -- stylua: ignore
    keys = {
      { '<leader>ww', function() require('wrapping-paper').wrap_line() end, desc = 'wrapping-paper: wrap line', },
    },
    dependencies = { 'MunifTanjim/nui.nvim' },
  },
  {
    'laytan/cloak.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'folke/twilight.nvim',
    cond = rvim.treesitter.enable and niceties,
    cmd = 'Twilight',
    opts = {
      context = 40,
      dimming = { alpha = 0.45, inactive = true },
      exclude = { 'alpha', 'git' },
    },
  },
  {
    'miversen33/sunglasses.nvim',
    cond = not minimal and niceties and false,
    event = 'UIEnter',
    cmd = { 'SunglassesEnable', 'SunglassesDisable' },
    opts = {
      filter_type = 'SHADE', -- TINT, NOSYNTAX, SHADE
      filter_percent = 0.35,
    },
    config = function(_, opts)
      require('sunglasses').setup(opts)
      vim.cmd('SunglassesDisable')
    end,
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
    cond = not minimal and niceties,
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
    -- stylua: ignore
    keys = {
      { '<localleader>ag', '<Cmd>CellularAutomaton game_of_life<CR>', desc = 'automaton: game of life', },
      { '<localleader>am', '<Cmd>CellularAutomaton make_it_rain<CR>', desc = 'automaton: make it rain', },
    },
  },
  {
    'tjdevries/sPoNGe-BoB.NvIm',
    cmd = { 'SpOnGeBoBiFy' },
    -- stylua: ignore
    keys = {
      { '<localleader>ab', '<cmd>SpOnGeBoBiFy<CR>', mode = { 'v' }, desc = 'SpOnGeBoB: SpOnGeBoBiFy', },
    },
  },
  {
    'tamton-aquib/zone.nvim',
    cond = not minimal and false,
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
    cond = not minimal and false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'tzachar/highlight-undo.nvim',
    cond = not minimal and niceties,
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
        winblend = 0,
      },
    },
  },
  {
    'kevinhwang91/nvim-hlslens',
    cond = not minimal and niceties,
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
        { HlSearchNear = { bg = { from = 'CursorLine' } } },
        { HlSearchLens = { bg = { from = 'CursorLine' } } },
        { HlSearchLensNear = { bg = { from = 'CursorLine' } } },
        {
          HlSearchLensSurround = {
            fg = { from = 'CursorLine', attr = 'bg' },
          },
        },
        {
          HlSearchLensNearSurround = {
            fg = { from = 'CursorLine', attr = 'bg' },
          },
        },
        { HlSearchLensNearIcon = { fg = { from = 'Comment' } } },
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
            -- chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLensNear' } }
            chunks = {
              { ' ', 'Ignore' },
              { '', 'HlSearchLensNearSurround' },
              { text, 'HlSearchLensNear' },
              { ' ', 'HlSearchLensNearSurround' },
            }
          else
            text = ('[%s %d]'):format(indicator, idx)
            -- chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
            chunks = {
              { ' ', 'Ignore' },
              { '', 'HlSearchLensSurround' },
              { text, 'HlSearchLens' },
              { '', 'HlSearchLensSurround' },
            }
          end
          render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
        end,
      })
    end,
  },
  {
    'folke/todo-comments.nvim',
    cond = niceties,
    event = 'BufReadPost',
    cmd = { 'TodoTelescope', 'TodoTrouble', 'TodoQuickFix', 'TodoDots' },
    -- stylua: ignore
    keys = {
      { '<localleader>tt', '<cmd>TodoDots<CR>', desc = 'todo: dotfiles todos' },
      { '<localleader>tj', function() require('todo-comments').jump_next() end, desc = 'todo-comments: next todo', },
      { '<localleader>tk', function() require('todo-comments').jump_prev() end, desc = 'todo-comments: prev todo', },
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
    'shellRaining/hlchunk.nvim',
    cond = not minimal and false,
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
    'LudoPinelli/comment-box.nvim',
    cond = not minimal and niceties,
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
