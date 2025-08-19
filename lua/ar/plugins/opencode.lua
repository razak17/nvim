local function ask(prompt)
  if prompt and prompt ~= '' then
    return function() require('opencode').ask(prompt) end
  else
    return function() require('opencode').ask() end
  end
end

local function oc(which)
  return function() require('opencode')[which]() end
end

return {
  {
    'NickvanDyke/opencode.nvim',
    cond = function() return ar.get_plugin_cond('opencode.nvim', ar.ai.enable) end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader>ao', group = 'Opencode' })
    end,
    opts = {},
    -- stylua: ignore
    keys = {
      { '<leader>aoo', oc("toggle"), desc = 'opencode: toggle' },
      { '<leader>aoa', ask(), desc = 'opencode: ask' },
      { '<leader>aob', ask('@buffer: '), desc = 'opencode: ask buffer' },
      { '<leader>aoB', ask('@buffers: '), desc = 'opencode: ask buffers' },
      { '<leader>aoc', ask('@cursor: '), desc = 'opencode: ask cursor' },
      { '<leader>aod', ask('@diagnostic: '), desc = 'opencode: ask diagnostic' },
      { '<leader>aoD', ask('@diagnostics: '), desc = 'opencode: ask diagnostic' },
      { '<leader>aoq', ask('@quickfix: '), desc = 'opencode: ask quickfix' },
      { '<leader>aos', ask('@selection: '), desc = 'opencode: ask selection', mode = 'v', },
      { '<leader>aop', oc("select_prompt"), desc = 'opencode: select prompt', mode = { 'n', 'v', }, },
      { '<leader>aon', function() require('opencode').command('session_new') end, desc = 'opencode: new session', },
      { '<leader>aoy', function() require('opencode').command('messages_copy') end, desc = 'opencode: copy last message', },
      { '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, desc = 'opencode: scroll messages up', },
      { '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, desc = 'opencode: scroll messages down', },
    },
  },
}
