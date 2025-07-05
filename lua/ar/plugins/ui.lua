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
    'nmac427/guess-indent.nvim',
    cond = function() return ui_cond('guess-indent.nvim') end,
    cmd = { 'GuessIndent' },
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
    'koron/nyancat-vim',
    cond = function() return ui_cond('nyancat-vim') end,
    cmd = { 'Nyancat', 'Nyancat2' },
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
}
