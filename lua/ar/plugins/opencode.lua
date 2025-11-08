local function oc(which, what, opts)
  what = what or nil
  opts = {
    clear = opts and opts.clear or false,
    submit = opts and opts.submit or true,
  }
  return function() require('opencode')[which](what, opts) end
end

local function ocf(which, opts)
  opts = opts or {}
  return function() require('opencode.api')[which](opts) end
end

local function choose_mode()
  local modes = {
    {
      name = 'Build Mode',
      description = 'Use an autonomous agent to handle complex tasks.',
      cmd = 'agent_build',
    },
    {
      name = 'Plan Mode',
      description = 'Create a multi-step plan before executing tasks.',
      cmd = 'agent_plan',
    },
    {
      name = 'Select Agent',
      description = 'Choose a specific agent for your task.',
      cmd = 'select_agent',
    },
  }
  vim.ui.select(modes, {
    prompt = 'Select OpenCode Mode:',
    format_item = function(item) return item.name .. ' - ' .. item.description end,
  }, function(choice)
    if choice then
      require('opencode.api')[choice.cmd]()
      vim.notify('OpenCode mode set to: ' .. choice.name, vim.log.levels.INFO)
    else
      vim.notify(
        'No mode selected. OpenCode mode unchanged.',
        vim.log.levels.WARN
      )
    end
  end)
end

local variant = ar_config.ai.opencode.variant

local function get_cond(plugin, which)
  local condition = ar.ai.enable and variant == which
  return ar.get_plugin_cond(plugin, condition)
end

return {
  {
    'NickvanDyke/opencode.nvim',
    cond = function() return get_cond('opencode.nvim', 'tui') end,
    init = function()
      vim.g.whichkey_add_spec({
        '<leader>ao',
        group = 'Opencode',
        mode = { 'n', 'x' },
      })
    end,
    opts = {},
    config = function(_, opts)
      ---@type opencode.Opts
      vim.g.opencode_opts = opts
    end,
    -- stylua: ignore
    keys = {
      { '<leader>aoo', oc('toggle'), desc = 'opencode: toggle' },
      { '<leader>aoa', oc('ask'), desc = 'opencode: ask' },
      { '<leader>aob', oc('ask', '@buffer: '), desc = 'opencode: ask buffer' },
      { '<leader>aoB', oc('ask', '@buffers: '), desc = 'opencode: ask buffers' },
      { '<leader>aoc', oc('ask', '@cursor: '), desc = 'opencode: ask cursor' },
      { '<leader>aod', oc('ask', '@diagnostic: '), desc = 'opencode: ask diagnostic' },
      { '<leader>aoD', oc('ask', '@diagnostics: '), desc = 'opencode: ask diagnostics' },
      { '<leader>aoq', oc('ask', '@quickfix: '), desc = 'opencode: ask quickfix' },
      { '<leader>aos', oc('ask', '@selection: '), desc = 'opencode: ask selection', mode = 'v', },
      { '<leader>aop', oc('select'), desc = 'opencode: select prompt', mode = { 'n', 'v', }, },
      { '<leader>aoe', oc('prompt', 'Explain @cursor and its context'), desc = 'opencode: explain this code' },
      { '<leader>aon', function() require('opencode').command('session_new') end, desc = 'opencode: new session', },
      { '<leader>aoy', function() require('opencode').command('messages_copy') end, desc = 'opencode: copy last message', },
      { '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, desc = 'opencode: scroll messages up', },
      { '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, desc = 'opencode: scroll messages down', },
    },
  },
  {
    'sudo-tee/opencode.nvim',
    cond = function() return get_cond('opencode.nvim', 'frontend') end,
    name = 'opencode-frontend.nvim',
    event = 'VeryLazy',
    init = function()
      vim.g.whichkey_add_spec({
        { '<leader>ah', group = 'Opencode', mode = { 'n', 'x' } },
      })
      vim.g.whichkey_add_spec({
        { '<leader>ah', group = 'Opencode', mode = { 'n', 'x' } },
        { '<leader>ahd', group = 'Diff', mode = { 'n', 'x' } },
        { '<leader>ahp', group = 'Permission', mode = { 'n', 'x' } },
        { '<leader>ahr', group = 'Revert/Restore', mode = { 'n', 'x' } },
      })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>aho', ocf('toggle'), desc = 'opencode: toggle' },
      { '<leader>ah:', ocf('initialize'), desc = 'opencode: initialize' },
      { '<leader>ahi', ocf('open_input'), desc = 'opencode: open input' },
      { '<leader>ahI', ocf('open_input_new_session'), desc = 'opencode: open input (new)' },
      { '<leader>ahO', ocf('open_output'), desc = 'opencode: open output' },
      { '<leader>ahn', ':Opencode session new ', desc = 'opencode: new named session' },
      { '<leader>ahh', ocf('toggle_focus'), desc = 'opencode: toggle focus' },
      { '<leader>ahq', ocf('close'), desc = 'opencode: close' },
      { '<leader>ahx', ocf('cancel'), desc = 'opencode: cancel' },
      { '<leader>ahp', ocf('select_session'), desc = 'opencode: select session' },
      { '<leader>ahS', ocf('select_child_session'), desc = 'opencode: select child session' },
      { '<leader>ahc', ocf('configure_provider'), desc = 'opencode: configure provider' },
      { '<leader>ahm', choose_mode, desc = 'opencode: choose mode' },
      { '<leader>ahM', ocf('mcp'), desc = 'opencode: available mcp servers' },
      { '<leader>ahs', ocf('share'), desc = 'opencode: share' },
      { '<leader>ahu', ocf('unshare'), desc = 'opencode: unshare' },
      { '<leader>ahk', ocf('compact_session'), desc = 'opencode: compact session' },
      { '<leader>ahU', ocf('undo'), desc = 'opencode: undo' },
      { '<leader>ahR', ocf('redo'), desc = 'opencode: redo' },
      { '<leader>ahH', ocf('swap_position'), desc = 'opencode: swap position' },
      --  Permission
      { '<leader>ahpa', ocf('permission_accept'), desc = 'opencode: accept permission' },
      { '<leader>ahpA', ocf('permission_accept_all'), desc = 'opencode: accept all permissions' },
      { '<leader>ahpx', ocf('permission_deny'), desc = 'opencode: deny permission' },
      --  Diff
      { '<leader>ahdo', ocf('diff_open'), desc = 'opencode: open diff' },
      { '<leader>ahdn', ocf('diff_next'), desc = 'opencode: next diff' },
      { '<leader>ahdp', ocf('diff_prev'), desc = 'opencode: previous diff' },
      { '<leader>ahdq', ocf('diff_close'), desc = 'opencode: close diff' },
      -- Revert
      { '<leader>ahra', ocf('diff_revert_all_last_prompt'), desc = 'opencode: revert all last prompt' },
      { '<leader>ahrt', ocf('diff_revert_this_last_prompt'), desc = 'opencode: revert this last prompt' },
      { '<leader>ahrA', ocf('diff_revert_all_session'), desc = 'opencode: revert all session' },
      { '<leader>ahrT', ocf('diff_revert_this_session'), desc = 'opencode: revert this session' },
      -- Revert to snapshot
      { '<leader>ahrS', ':Opencode revert all_to_snapshot<CR>', desc = 'opencode: revert all to snapshot' },
      { '<leader>ahrs', ':Opencode revert this_to_snapshot<CR>', desc = 'opencode: revert file to snapshot' },
      -- Restore from snapshot
      { '<leader>ahrr', ':Opencode restore snapshot_file<CR>', desc = 'opencode: restore file to restore point' },
      { '<leader>ahrR', ':Opencode restore snapshot_all<CR>', desc = 'opencode: restore all to restore point' },
    },
    opts = {
      preferred_picker = nil, -- 'telescope', 'fzf', 'mini.pick', 'snacks', if nil, it will use the best available picker. Note mini.pick does not support multiple selections
      preferred_completion = nil, -- 'blink', 'nvim-cmp','vim_complete' if nil, it will use the best available completion
      default_global_keymaps = false, -- If false, disables all default global keymaps
      default_mode = 'build', -- 'build' or 'plan' or any custom configured. @see [OpenCode Agents](https://opencode.ai/docs/modes/)
      keymap_prefix = '', -- Default keymap prefix for global keymaps change to your preferred prefix and it will be applied to all keymaps starting with <leader>o
      ui = {
        input = {
          text = { wrap = true },
        },
      },
      keymap = {
        input_window = {},
        output_window = {},
      },
    },
  },
}
