local fmt = string.format
local bookmark = ar.ui.codicons.misc.bookmark

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

return {
  {
    desc = 'TrailBlazer enables you to seemlessly move through important project marks as quickly and efficiently as possible to make your workflow blazingly fast ™.',
    'LeonHeidelbach/trailblazer.nvim',
    cond = function() return ar.get_plugin_cond('trailblazer.nvim') end,
    -- stylua: ignore
    keys = {
      '<A-l>',
      { '<leader>mA', add_trail_mark_stack, desc = 'trailblazer: add stack' },
      { '<leader>md', delete_trail_mark_stack, desc = 'trailblazer: delete stack', },
      { '<leader>mg', function() get_available_stacks(true) end, desc = 'trailblazer: get stacks', },
      { '<leader>ms', '<Cmd>TrailBlazerSaveSession<CR>', desc = 'trailblazer: save session', },
      { '<leader>ml', '<Cmd>TrailBlazerLoadSession<CR>', desc = 'trailblazer: load session', },
    },
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
}
