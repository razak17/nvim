local models = ar_config.ai.models
local tiny_diags_disabled_by_nes = false

return {
  {
    'Davidyz/VectorCode',
    cond = function() return ar.get_plugin_cond('VectorCode', ar.ai.enable) end,
    version = '*',
    build = 'uv tool upgrade vectorcode',
    cmd = 'VectorCode',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'folke/sidekick.nvim',
    cond = false,
    lazy = true,
    opts = {
      nes = {
        enabled = true,
      },
      mux = {
        backend = 'tmux',
        enabled = true,
      },
      cli = {
        win = {
          keys = {
            stopinsert = { '<esc>', 'stopinsert', mode = 't' }, -- enter normal mode
            win_p = { '<M-Left>', 'blur' },
          },
        },
      },
    },
    init = function()
      vim.g.whichkey_add_spec({
        '<leader>as',
        group = 'Sidekick',
        mode = { 'n', 'x' },
      })
    end,
    keys = {
      {
        '<leader>aso',
        function() require('sidekick.cli').toggle() end,
        desc = 'sidekick: toggle cli',
      },
      {
        '<leader>ass',
        function() require('sidekick.cli').select() end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = 'sidekick: select cli',
      },
      {
        '<leader>ast',
        function() require('sidekick.cli').send({ msg = '{this}' }) end,
        mode = { 'x', 'n' },
        desc = 'sidekick: send this',
      },
      {
        '<leader>asv',
        function() require('sidekick.cli').send({ msg = '{selection}' }) end,
        mode = { 'x' },
        desc = 'sidekick: send visual selection',
      },
      {
        '<leader>asp',
        function() require('sidekick.cli').prompt() end,
        mode = { 'n', 'x' },
        desc = 'sidekick: select prompt',
      },
      {
        '<leader>af',
        function() require('sidekick.cli').send({ msg = '{file}' }) end,
        desc = 'sidekick: send file',
      },
      {
        '<c-.>',
        function() require('sidekick.cli').toggle() end,
        mode = { 'n', 't', 'i', 'x' },
        desc = 'sidekick: toggle',
      },
    },
    config = function(_, opts)
      require('sidekick').setup(opts)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'SidekickNesHide',
        callback = function()
          if tiny_diags_disabled_by_nes then
            tiny_diags_disabled_by_nes = false
            require('tiny-inline-diagnostic').enable()
          end
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'SidekickNesShow',
        callback = function()
          tiny_diags_disabled_by_nes = true
          require('tiny-inline-diagnostic').disable()
        end,
      })
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
