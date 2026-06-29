local fmt = string.format
local minimal = ar.plugins.minimal
local bookmark = ar.ui.codicons.misc.bookmark

return {
  {
    desc = 'TrailBlazer enables you to seemlessly move through important project marks as quickly and efficiently as possible to make your workflow blazingly fast ™.',
    'LeonHeidelbach/trailblazer.nvim',
    cond = function() return ar.get_plugin_cond('trailblazer.nvim') end,
    keys = function()
      local function get_available_stacks(notify)
        local available_stacks =
          require('trailblazer.trails').stacks.get_sorted_stack_names()
        if notify then
          vim.notify(
            fmt('Available stacks: %s', table.concat(available_stacks, ', ')),
            'info',
            { title = 'TrailBlazer' }
          )
        end
        return available_stacks
      end
      local function add_trail_mark_stack()
        vim.ui.input({ prompt = 'stack name: ' }, function(name)
          if not name then return end
          local available_stacks = get_available_stacks()
          if vim.tbl_contains(available_stacks, name) then
            vim.notify(
              fmt('"%s" stack already exists.', name),
              'warn',
              { title = 'TrailBlazer' }
            )
            return
          end
          local tb = require('trailblazer')
          tb.add_trail_mark_stack(name)
          vim.notify(
            fmt('"%s" stack created.', name),
            'info',
            { title = 'TrailBlazer' }
          )
        end)
      end
      local function delete_trail_mark_stack()
        vim.ui.input({ prompt = 'stack name: ' }, function(name)
          if not name then return end
          local available_stacks = get_available_stacks()
          if not vim.tbl_contains(available_stacks, name) then
            vim.notify(
              fmt('"%s" stack does not exist.', name),
              'warn',
              { title = 'TrailBlazer' }
            )
            return
          end
          local tb = require('trailblazer')
          tb.delete_trail_mark_stack(name)
          vim.notify(
            fmt('"%s" stack deleted.', name),
            'info',
            { title = 'TrailBlazer' }
          )
        end)
      end
      -- stylua: ignore
      return {
        '<A-l>',
        { '<leader>mA', add_trail_mark_stack, desc = 'trailblazer: add stack' },
        { '<leader>md', delete_trail_mark_stack, desc = 'trailblazer: delete stack', },
        { '<leader>mg', function() get_available_stacks(true) end, desc = 'trailblazer: get stacks', },
        { '<leader>ms', '<Cmd>TrailBlazerSaveSession<CR>', desc = 'trailblazer: save session', },
        { '<leader>ml', '<Cmd>TrailBlazerLoadSession<CR>', desc = 'trailblazer: load session', },
      }
    end,
    opts = {
      auto_save_trailblazer_state_on_exit = true,
      auto_load_trailblazer_state_on_enter = false,
      trail_mark_symbol_line_indicators_enabled = true,
      custom_session_storage_dir = join_paths(
        vim.fn.stdpath('data'),
        'trailblazer'
      ),
      trail_options = {
        newest_mark_symbol = bookmark,
        cursor_mark_symbol = bookmark,
        next_mark_symbol = bookmark,
        previous_mark_symbol = bookmark,
        number_line_color_enabled = false,
      },
      mappings = {
        nv = {
          motions = {
            peek_move_next_down = '<A-j>',
            peek_move_previous_up = '<A-k>',
          },
        },
      },
    },
  },
  {
    desc = 'Neovim plugin for tagging important files',
    'cbochs/grapple.nvim',
    cond = function() return ar.get_plugin_cond('grapple.nvim', not minimal) end,
    keys = function()
      -- https://www.reddit.com/r/neovim/comments/1nbiv93/combining_best_of_marks_and_harpoon_with_grapple/
      local function save_mark()
        local char = vim.fn.getcharstr()
        -- Handle ESC, Ctrl-C, etc.
        if char == '' or vim.startswith(char, '<') then return end
        local grapple = require('grapple')
        grapple.tag({ name = char })
        local filepath = vim.api.nvim_buf_get_name(0)
        local filename = vim.fn.fnamemodify(filepath, ':t')
        vim.notify('Marked ' .. filename .. ' as ' .. char)
      end
      local function open_mark()
        local char = vim.fn.getcharstr()
        -- Handle ESC, Ctrl-C, etc.
        if char == '' or vim.startswith(char, '<') then return end
        local grapple = require('grapple')
        if char == "'" then
          grapple.toggle_tags()
          return
        end
        grapple.select({ name = char })
      end
      -- stylua: ignore
      return {
        { 'm', save_mark, noremap = true, silent = true },
        { "'", open_mark, noremap = true, silent = true },
        { '<A-a>', '<Cmd>Grapple toggle<CR>', desc = 'grapple: add file' },
        { '<A-m>', '<Cmd>Grapple toggle_tags<CR>', desc = 'grapple: toggle tags' },
      }
    end,
    cmd = 'Grapple',
    opts = {
      scope = 'git_branch',
      default_scopes = {
        git = { shown = true },
        git_branch = { shown = true },
        global = { shown = true },
      },
    },
  },
  {
    'razak17/tide.nvim',
    cond = function() return ar.get_plugin_cond('tide.nvim') end,
    -- event = 'VeryLazy',
    init = function()
      vim.g.whichkey_add_spec({
        { ';j', group = 'tide' },
        { ';jd', group = 'tide: delete' },
        { ';j-', group = 'tide: horizontal open' },
        { ';j|', group = 'tide: vertical open' },
        { ';ja', group = 'tide: add item' },
        { ';jx', group = 'tide: clear all' },
      })
    end,
    keys = { ';j' },
    opts = {
      keys = {
        leader = ';j', -- Leader key to prefix all Tide commands
        panel = ';', -- Open the panel (uses leader key as prefix)
        add_item = 'a', -- Add a new item to the list (leader + 'a')
        delete = 'd', -- Remove an item from the list (leader + 'd')
        clear_all = 'x', -- Clear all items (leader + 'x')
        horizontal = '-', -- Split window horizontally (leader + '-')
        vertical = '|', -- Split window vertically (leader + '|')
      },
      hints = {
        dictionary = 'uiopbnmsfghjklycvqwertz', -- Key hints for quick access
      },
    },
    config = function(_, opts)
      require('tide').setup(opts)
      ar.highlight.plugin('tide', { { TideBg = { link = 'NormalFloat' } } })
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    desc = 'Neovim plugin for improved location list navigation',
    'cbochs/portal.nvim',
    cond = function() return ar.get_plugin_cond('portal.nvim') end,
    -- stylua: ignore
    keys = {
      { 'g<c-i>', '<Cmd>Portal jumplist forward<CR>', desc = 'portal jump backward' },
      { 'g<c-o>', '<Cmd>Portal jumplist backward<CR>', desc = 'portal jump forward' },
    },
    opts = {},
  },
  {
    desc = 'Show jumplist in a floating window.',
    'razak17/whatthejump.nvim',
    cond = function()
      return ar.get_plugin_cond('whatthejump.nvim', not minimal)
    end,
    keys = { '<C-o>', '<C-i>' },
    opts = { winblend = 0 },
  },
}
