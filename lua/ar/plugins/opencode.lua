local function oc(which, opts)
  opts = opts or nil
  return function() require('opencode')[which](opts) end
end

return {
  {
    'NickvanDyke/opencode.nvim',
    cond = function() return ar.get_plugin_cond('opencode.nvim', ar.ai.enable) end,
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
}
