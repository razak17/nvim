local fmt = string.format
local bookmark = ar.ui.codicons.misc.bookmark
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

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
    if ar.find_string(available_stacks, name) then
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
    if not ar.find_string(available_stacks, name) then
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
            peek_move_next_down = '<M-k>',
            peek_move_previous_up = '<M-j>',
          },
        },
      },
    },
  },
  {
    'cbochs/grapple.nvim',
    cond = not minimal,
    opts = {
      scope = 'git_branch',
      default_scopes = {
        git = { shown = true },
        git_branch = { shown = true },
        global = { shown = true },
      },
    },
    cmd = 'Grapple',
    keys = {
      { '<leader>ma', '<Cmd>Grapple toggle<CR>', desc = 'grapple: toggle tag' },
      { '<leader>M', '<Cmd>Grapple toggle_tags<CR>', 'grapple: toggle tags' },
    },
  },
  {
    'ThePrimeagen/harpoon',
    cond = not minimal,
    branch = 'harpoon2',
    -- stylua: ignore
    keys = function()
      local keys = {
        {
          '<M-;>',
          function()
            local harpoon = require('harpoon')
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = 'toggle quick menu',
        },
        { '<localleader>ha', function() require('harpoon'):list():append() end, desc = 'harpoon: add' },
        { '<localleader>hn', function() require('harpoon').list():next() end, desc = 'harpoon: next' },
        { '<localleader>hp', function() require('harpoon').list():prev() end, desc = 'harpoon: prev' },
      }

      for i = 1, 5 do
        table.insert(keys, {
          '<localleader>h' .. i,
          function() require('harpoon'):list():select(i) end,
          desc = 'harpoon to file ' .. i,
        })
      end
      return keys
    end,
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
    },
  },
  {
    'otavioschwanck/arrow.nvim',
    cond = not minimal,
    -- stylua: ignore
    keys = {
      '\\',
      { '<M-s>', '<Cmd>lua require("arrow.persist").toggle()<CR>', desc = 'arrow: toggle' },
      { '<M-n>', '<Cmd>lua require("arrow.persist").next()<CR>', desc = 'arrow: next'},
      { '<M-p>', '<Cmd>lua require("arrow.persist").previous()<CR>', desc = 'arrow: prev'}
    },
    opts = { show_icons = true, leader_key = '\\' },
    config = function(_, opts)
      require('arrow').setup(opts)
      require('arrow.persist').toggle()
    end,
  },
  {
    'cbochs/portal.nvim',
    cond = not minimal,
    -- stylua: ignore
    keys = {
      { 'g<c-i>', '<Cmd>Portal jumplist forward<CR>', desc = 'portal jump backward' },
      { 'g<c-o>', '<Cmd>Portal jumplist backward<CR>', desc = 'portal jump forward' },
    },
    opts = {},
  },
  {
    'razak17/whatthejump.nvim',
    cond = not minimal,
    keys = { '<C-o>', '<C-i>', '<M-o>', '<M-i>' },
    -- event = { 'BufRead', 'BufNewFile' },
    opts = { winblend = 0 },
    config = function(_, opts)
      require('whatthejump').setup(opts)

      map('n', '<M-o>', function()
        require('whatthejump').show_jumps(false)
        return '<C-o>'
      end, { expr = true })

      map('n', '<M-i>', function()
        require('whatthejump').show_jumps(true)
        return '<C-i>'
      end, { expr = true })
    end,
  },
  {
    'bloznelis/before.nvim',
    cond = not minimal and niceties,
    event = { 'BufRead', 'BufNewFile' },
    -- stylua: ignore
    keys = {
      { '<localleader>oj', '<Cmd>lua require("before").jump_to_last_edit()<CR>', desc = 'before: jump to last edit' },
      { '<localleader>ok', '<Cmd>lua require("before").jump_to_next_edit()<CR>', desc = 'before: jump to next edit' },
      { '<localleader>oq', '<Cmd>lua require("before").show_edits_in_quickfix()<CR>', desc = 'before: show edits in qflist' },
      { '<localleader>op', '<Cmd>lua require("before").show_edits_in_telescope()<CR>', desc = 'before: show edits in picker' },
    },
    opts = {},
    config = function(_, opts) require('before').setup(opts) end,
  },
}
