local ui, highlight = ar.ui, ar.highlight
local icons, separators = ui.icons, ui.icons.separators

local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

local ui_cond = function(plugin, cond)
  if cond == nil then cond = true end
  local condition = not minimal and niceties and cond
  return ar.get_plugin_cond(plugin, condition)
end

return {
  {
    'razak17/spaceless.nvim',
    lazy = false,
    cond = function() return ar.get_plugin_cond('spaceless.nvim', not minimal) end,
  },
  {
    'razak17/lspkind.nvim',
    config = function() require('lspkind').init({ preset = 'codicons' }) end,
  },
  {
    'OXY2DEV/helpview.nvim',
    cond = function() return ui_cond('helpview.nvim', ar.ts_extra_enabled) end,
    lazy = false,
    init = function()
      ar.add_to_select_menu(
        'toggle',
        { ['Toggle Helpview'] = 'Helpview toggleAll' }
      )
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'nmac427/guess-indent.nvim',
    cond = function() return ui_cond('guess-indent.nvim') end,
    event = 'BufReadPost',
    config = function() require('guess-indent').setup({}) end,
  },
  {
    'Aasim-A/scrollEOF.nvim',
    cond = not minimal and false, -- NOTE: stay-centered kinda makes this redundant, Keep for when it is toggled off
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'ObserverOfTime/notifications.nvim',
    cond = false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'karb94/neoscroll.nvim',
    cond = function() return ar.get_plugin_cond('neoscroll.nvim', not minimal) end,
    event = 'BufRead',
    opts = {
      mappings = { '<C-d>', '<C-u>', '<C-y>', 'zt', 'zz', 'zb' },
      hide_cursor = true,
    },
  },
  {
    'razak17/smartcolumn.nvim',
    cond = function()
      return ar.get_plugin_cond('smartcolumn.nvim', not minimal)
    end,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      colorcolumn = '0',
      custom_autocommand = true,
    },
  },
  {
    'Pocco81/HighStr.nvim',
    cond = function() return ui_cond('HighStr.nvim') end,
    cmd = { 'HSHighlight', 'HSRmHighlight', 'HSImport' },
    opts = {},
    config = function(_, opts) require('high-str').setup(opts) end,
  },
  {
    'koron/nyancat-vim',
    cond = function() return ui_cond('nyancat-vim') end,
    cmd = { 'Nyancat', 'Nyancat2' },
  },
  {
    'HampusHauffman/block.nvim',
    cond = function() return ui_cond('block.nvim') end,
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
    'razak17/nvim-strict',
    cond = function() return ui_cond('nvim-strict') end,
    event = { 'BufReadPost', 'BufNewFile' },
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>s', group = 'Strict' })
    end,
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
      excluded_filetypes = {
        'buffalo',
        'buffer_manager',
        'fzf',
        'harpoon',
        'minifiles',
        'NeogitPopup',
        'NeogitStatus',
        'oil',
        'TelescopePrompt',
        'qf',
      },
      excluded_buftypes = {
        'help',
        'nofile',
        'terminal',
        'prompt',
        'quickfix',
      },
      deep_nesting = {
        highlight_group = 'Strict',
        depth_limit = 4,
        ignored_trailing_characters = ',',
        ignored_leading_characters = '.',
      },
      overlong_lines = {
        highlight_group = 'Strict',
        length_limit = 100,
        split_on_save = false,
      },
      todos = { highlight = false },
    },
    config = function(_, opts) require('strict').setup(opts) end,
  },
  {
    'tzachar/local-highlight.nvim',
    cond = function() return ui_cond('local-highlight.nvim', not ar.lsp.enable) end,
    event = { 'BufRead', 'BufNewFile' },
    opts = { hlgroup = 'CursorLine' },
  },
  {
    'razak17/range-highlight.nvim',
    cond = function() return ui_cond('range-highlight.nvim') end,
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'winston0410/cmd-parser.nvim' },
    opts = {},
  },
  {
    'folke/twilight.nvim',
    cond = function() return ar.get_plugin_cond('twilight.nvim', niceties) end,
    cmd = 'Twilight',
    init = function()
      ar.add_to_select_menu('toggle', { ['Toggle Twilight'] = 'Twilight' })
    end,
    opts = {
      context = 40,
      dimming = { alpha = 0.45, inactive = true },
      exclude = { 'alpha', 'git' },
    },
  },
  {
    'tjdevries/sPoNGe-BoB.NvIm',
    cmd = { 'SpOnGeBoBiFy' },
    init = function()
      ar.add_to_select_menu('toggle', { ['Toggle SpOnGeBoB'] = 'SpOnGeBoBiFy' })
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>ab', '<cmd>SpOnGeBoBiFy<CR>', mode = { 'v' }, desc = 'SpOnGeBoB: SpOnGeBoBiFy', },
    },
  },
  {
    'kevinhwang91/nvim-hlslens',
    cond = function() return ui_cond('nvim-hlslens') end,
    event = { 'BufRead', 'BufNewFile' },
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
        -- stylua: ignore
        theme = {
          ['onedark'] = {
            { HlSearchNear = { bg = { from = 'CursorLine' } } },
            { HlSearchLens = { bg = { from = 'CursorLine' } } },
            { HlSearchLensNear = { bg = { from = 'CursorLine' } } },
            { HlSearchLensSurround = { fg = { from = 'CursorLine', attr = 'bg' } } },
            { HlSearchLensNearSurround = { fg = { from = 'CursorLine', attr = 'bg' } } },
            { HlSearchLensNearIcon = { fg = { from = 'Comment' } } },
          },
        },
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
    cond = function()
      return ar.get_plugin_cond('todo-comments.nvim', not minimal)
    end,
    event = 'BufReadPost',
    cmd = { 'TodoTelescope', 'TodoTrouble', 'TodoQuickFix', 'TodoDots' },
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>t', group = 'TODO' })
    end,
    -- stylua: ignore
    keys = {
      -- { '<localleader>tt', '<cmd>TodoDots<CR>', desc = 'todo: dotfiles todos' },
      { '<localleader>tt', function() Snacks.picker.todo_comments() end, desc = 'Todo' },
      { '<leader>sT', function () Snacks.picker.todo_comments({ keywords = { 'TODO', 'FIX', 'FIXME' } }) end, desc = 'Todo/Fix/Fixme' },
      { '<localleader>tj', function() require('todo-comments').jump_next() end, desc = 'todo-comments: next todo', },
      { '<localleader>tk', function() require('todo-comments').jump_prev() end, desc = 'todo-comments: prev todo', },
    },
    config = function()
      require('todo-comments').setup({ highlight = { after = '' } })
      ar.command(
        'TodoDots',
        string.format(
          'TodoTelescope cwd=%s keywords=TODO,FIXME',
          vim.fn.stdpath('config')
        )
      )
    end,
  },
  {
    'LudoPinelli/comment-box.nvim',
    cond = function() return ui_cond('comment-box.nvim') end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader><leader>b', group = 'Comment Box' })
    end,
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
  {
    'gregorias/toggle.nvim',
    cond = function() return ui_cond('toggle.nvim') end,
    event = { 'VeryLazy' },
    opts = {
      keymaps = {
        toggle_option_prefix = 'yp',
        previous_option_prefix = '[o',
        next_option_prefix = ']o',
        status_dashboard = 'yos',
      },
    },
  },
  {
    'GitMarkedDan/you-are-an-idiot.nvim',
    cond = function()
      return ar.get_plugin_cond('you-are-an-idiot.nvim', not minimal)
    end,
    cmd = { 'ToggleIdiot' },
    init = function()
      ar.add_to_select_menu('toggle', { ['Toggle Idiot'] = 'ToggleIdiot' })
    end,
    config = function()
      local idiot = require('you-are-an-idiot')
      vim.api.nvim_create_user_command('ToggleIdiot', function()
        if idiot.is_running() then
          idiot.abort()
        else
          idiot.run()
        end
      end, { desc = 'Toggles YouAreAnIdiot' })
    end,
  },
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'folke/zen-mode.nvim',
    enabled = false,
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>z', group = 'Zen' })
      ar.add_to_select_menu('toggle', { ['Toggle ZenMode'] = 'ZenMode' })
    end,
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
    'tomiis4/BufferTabs.nvim',
    enabled = false,
    cond = not minimal and false,
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
    'mei28/luminate.nvim',
    enabled = false,
    cond = not minimal and niceties and false,
    event = { 'VeryLazy' },
    opts = {},
  },
  {
    'lukas-reineke/virt-column.nvim',
    enabled = false,
    cond = function()
      return ar.get_plugin_cond('virt-column.nvim', not minimal)
    end,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      char = separators.right_thin_block,
      highlight = 'IndentBlanklineContextChar',
    },
  },
  {
    'AndrewRadev/discotheque.vim',
    enabled = false,
    cond = not minimal and niceties and false,
    cmd = { 'Disco' },
  },
  {
    'utilyre/sentiment.nvim',
    enabled = false,
    cond = not minimal and niceties and false,
    init = function()
      -- `matchparen.vim` needs to be disabled manually in case of lazy loading
      vim.g.loaded_matchparen = 1
    end,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      excluded_filetypes = {
        [''] = true,
        fugitive = true,
      },
    },
  },
  {
    'aaron-p1/match-visual.nvim',
    enabled = false,
    cond = not minimal and niceties and false,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'miversen33/sunglasses.nvim',
    enabled = false,
    cond = not minimal and niceties and false,
    event = 'UIEnter',
    cmd = { 'SunglassesEnable', 'SunglassesDisable' },
    opts = {
      filter_type = 'SHADE', -- TINT, NOSYNTAX, SHADE
      filter_percent = 0.35,
    },
    init = function()
      local function toggle_sunglasses()
        if not ar.plugin_available('sunglasses.nvim') then return end
        local is_shaded
        for _, winnr in ipairs(vim.api.nvim_list_wins()) do
          is_shaded = require('sunglasses.window').get(winnr):is_shaded()
          if is_shaded then
            vim.cmd('SunglassesDisable')
            return
          end
        end
        vim.cmd('SunglassesEnable')
        vim.cmd('SunglassesOff')
      end

      ar.add_to_select_menu(
        'toggle',
        { ['Toggle Sunglasses'] = toggle_sunglasses }
      )
    end,
    config = function(_, opts)
      require('sunglasses').setup(opts)
      vim.cmd('SunglassesDisable')
    end,
  },
  {
    'tamton-aquib/zone.nvim',
    enabled = false,
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
}
