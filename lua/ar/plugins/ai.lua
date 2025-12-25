local models = ar.config.ai.models

local function a(action)
  return function() require('agentic')[action]() end
end

return {
  -- FIX: Causes performance issues in insert mode
  {
    'carlos-algms/agentic.nvim',
    event = 'VeryLazy',
    cond = function() return ar.get_plugin_cond('agentic.nvim', ar.ai.enable) end,
    init = function()
      vim.g.whichkey_add_spec({
        '<leader>aa',
        group = 'Agentic',
        mode = { 'n', 'x' },
      })
    end,
    -- stylua: ignore
    keys = {
      { mode = { 'n', 'x', 'i' }, '<leader>aao', a('toggle'), desc = 'agentic: toggle' },
      { mode = { 'n', 'x' }, '<leader>aac', a('add_selection_or_file_to_context'), desc = 'agentic: add file or selection to context' },
      { mode = { 'n', 'x' }, '<leader>aaf', a('add_file'), desc = 'agentic: add file to context' },
      { mode = { 'n', 'x' }, '<leader>aas', a('add_selection'), desc = 'agentic: add selection to context' },
      { mode = { 'n', 'x', 'i' }, '<leader>aan', a('new_session'), desc = 'agentic: new session' },
    },
    opts = { provider = 'opencode-acp' },
    config = function(_, opts)
      require('agentic').setup(opts)
      ar.highlight.plugin(
        'agentic.nvim',
        { { AgenticTitle = { link = 'FloatTitle' } } }
      )
    end,
  },
  {
    'kylesnowschwartz/prompt-tower.nvim',
    cond = function()
      return ar.get_plugin_cond('prompt-tower.nvim', ar.ai.enable)
    end,
    init = function()
      ar.add_to_select_menu('ai', {
        ['Prompt Tower'] = function()
          ar.create_select_menu('Prompt Tower', {
            ['UI'] = 'PromptTower ui',
            ['Clear'] = 'PromptTower clear',
            ['Select'] = 'PromptTower select',
            ['Format'] = 'PromptTower format',
            ['Generate'] = 'PromptTower generate',
          })()
        end,
      })
    end,
    cmd = { 'PromptTower' },
    config = function()
      require('prompt-tower').setup({
        output_format = {
          default_format = 'markdown', -- Options: 'xml', 'markdown', 'minimal'
        },
      })
    end,
  },
  {
    'piersolenski/wtf.nvim',
    cond = function()
      local condition = ar.lsp.enable and ar.ai.enable and models.openai
      return ar.get_plugin_cond('wtf.nvim', condition)
    end,
    init = function() vim.g.whichkey_add_spec({ '<leader>aw', group = 'wtf' }) end,
    -- stylua: ignore
    keys = {
      { '<leader>awo', function() require('wtf').ai() end, desc = 'wtf: debug diagnostic with AI', },
      { '<leader>awg', function() require('wtf').search() end, desc = 'wtf: google search diagnostic', },
    },
    opts = {
      popup_type = 'horizontal', -- | 'popup' | 'horizontal' | 'vertical',
      language = 'english',
      search_engine = 'google', -- 'google' | 'duck_duck_go' | 'stack_overflow' | 'github',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
    },
  },
}
