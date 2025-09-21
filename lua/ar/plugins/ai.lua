local models = ar_config.ai.models

return {
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
