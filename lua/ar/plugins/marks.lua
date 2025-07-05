local fmt = string.format
local bookmark = ar.ui.codicons.misc.bookmark
local minimal = ar.plugins.minimal

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
  {
    desc = 'Neovim plugin for tagging important files',
    'cbochs/grapple.nvim',
    cond = function() return ar.get_plugin_cond('grapple.nvim', not minimal) end,
    -- stylua: ignore
    keys = {
      { '<leader>ma', '<Cmd>Grapple toggle<CR>', desc = 'grapple: add file' },
      { '<leader>mm', '<Cmd>Grapple toggle_tags<CR>', desc = 'grapple: toggle tags' },
    },
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
    desc = 'Neovim plugin for improved location list navigation',
    'cbochs/portal.nvim',
    cond = function() return ar.get_plugin_cond('portal.nvim', not minimal) end,
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
}
