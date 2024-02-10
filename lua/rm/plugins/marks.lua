local ui = rvim.ui
local fmt = string.format
local bookmark = rvim.ui.codicons.misc.bookmark

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
    if rvim.find_string(available_stacks, name) then
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
    if not rvim.find_string(available_stacks, name) then
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
    'LeonHeidelbach/trailblazer.nvim',
    -- stylua: ignore
    keys = {
      '<M-l>',
      { '<leader>ma', add_trail_mark_stack, desc = 'trailblazer: add stack' },
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
            peek_move_next_down = '<M-k>',
            peek_move_previous_up = '<M-j>',
          },
        },
      },
    },
  },
  {
    'razak17/harpoon',
    branch = 'harpoon2',
    -- stylua: ignore
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({ borderchars = ui.border.common })
      map("n", "<M-;>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
      map('n', '<localleader>ha', function() harpoon:list():append() end, { desc = 'harpoon: add'})
      map('n', '<localleader>hn', function() harpoon:list():next() end, { desc = 'harpoon: next'})
      map('n', '<localleader>hp', function() harpoon:list():prev() end, { desc = 'harpoon: prev'})
      map('n', '<M-1>', function() harpoon:list():select(1) end)
      map('n', '<M-2>', function() harpoon:list():select(2) end)
      map('n', '<M-3>', function() harpoon:list():select(3) end)
      map('n', '<M-4>', function() harpoon:list():select(4) end)
    end,
  },
  {
    'otavioschwanck/arrow.nvim',
    event = { 'BufRead', 'BufNewFile' },
    -- stylua: ignore
    keys = {
      { '<M-s>', '<Cmd>lua require("arrow.persist").toggle()<CR>', desc = 'arrow: toggle' },
      { '<M-n>', '<Cmd>lua require("arrow.persist").next()<CR>', desc = 'arrow: next'},
      { '<M-p>', '<Cmd>lua require("arrow.persist").previous()<CR>', desc = 'arrow: prev'}
    },
    opts = { show_icons = true, leader_key = '\\' },
    config = function(_, opts)
      require('arrow').setup(opts)
      require("arrow.persist").toggle()
    end
  },
}
