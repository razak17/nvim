local enabled = not ar.plugins.minimal and ar.lsp.enable

ar.pack.add({
  {
    src = 'https://github.com/kosayoda/nvim-lightbulb',
    cond = function() return ar.get_plugin_cond('nvim-lightbulb', enabled) end,
    event = 'LspAttach',
    setup = function()
      require('nvim-lightbulb').setup({
        autocmd = { enabled = true },
        sign = { enabled = false },
        virtual_text = { enabled = true, hl_mode = 'combine' },
      })
    end,
  },
  {
    -- A Neovim plugin that provides a simple way to run and visualize code actions with Telescope.
    src = 'https://github.com/rachartier/tiny-code-action.nvim',
    cond = function()
      local condition = enabled
        and ar.config.lsp.code_actions.variant == 'tiny-code-action'

      return ar.get_plugin_cond('tiny-code-action.nvim', condition)
    end,
    event = { 'LspAttach' },
    init = function()
      ar.augroup('TinyCodeActions', {
        event = { 'LspAttach' },
        command = function(args)
          map(
            'n',
            '<leader>laa',
            function() require('tiny-code-action').code_action() end,
            {
              buffer = args.buf,
              noremap = true,
              silent = true,
              desc = 'tiny-code-action: code action',
            }
          )
        end,
      })
    end,
    setup = function()
      require('tiny-code-action').setup({
        backend = 'delta',
        -- picker = 'snacks',
        picker = {
          'buffer',
          opts = {
            hotkeys = true,
            auto_preview = false,
            hotkeys_mode = 'text_diff_based',
          },
        },
        backend_opts = {
          delta = {
            args = { '--config=' .. vim.env.HOME .. '/gitconfig' },
          },
        },
      })
    end,
    dependencies = { { src = 'https://github.com/nvim-lua/plenary.nvim' } },
  },
  {
    -- Fully customizable previewer for LSP code actions.
    src = 'https://github.com/aznhe21/actions-preview.nvim',
    cond = function()
      return ar.get_plugin_cond('actions-preview.nvim', enabled)
    end,
    -- stylua: ignore
    keys = { { '<leader>lap', function() require('actions-preview').code_actions() end, desc = 'code action preview' }, },
    setup = function()
      require('actions-preview').setup({
        backend = { 'snacks', 'telescope', 'minipick', 'nui' },
        telescope = function() ar.telescope.vertical() end,
      })
    end,
  },
})
