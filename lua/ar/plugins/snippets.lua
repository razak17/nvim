return {
  'rafamadriz/friendly-snippets',
  's1n7ax/nvim-ts-utils',
  { 's1n7ax/nvim-snips', name = 'snips' },
  {
    'garymjr/nvim-snippets',
    cond = ar.completion.enable and false,
    event = 'InsertEnter',
    opts = {
      friendly_snippets = true,
      extended_filetypes = {
        typescript = { 'javascript', 'javascriptreact', 'jsdoc' },
        typescriptreact = { 'javascript', 'javascriptreact', 'jsdoc' },
      },
      search_paths = {
        join_paths(vim.fn.stdpath('config'), 'snippets', 'textmate'),
        -- join_paths(vim.fn.stdpath('data'), 'lazy', 'friendly-snippets'),
      },
    },
    dependencies = { 'rafamadriz/friendly-snippets' },
  },
  {
    'L3MON4D3/LuaSnip',
    event = 'InsertEnter',
    build = 'make install_jsregexp',
    keys = {
      { '<leader>S', '<cmd>LuaSnipEdit<CR>', desc = 'LuaSnip: edit snippet' },
    },
    config = function()
      local ls = require('luasnip')
      local types = require('luasnip.util.types')
      local extras = require('luasnip.extras')
      local fmt = require('luasnip.extras.fmt').fmt

      ls.config.set_config({
        history = false,
        region_check_events = 'CursorMoved,CursorHold,InsertEnter',
        delete_check_events = 'InsertLeave',
        ext_opts = {
          [types.choiceNode] = {
            active = {
              hl_mode = 'combine',
              virt_text = { { '●', 'Operator' } },
            },
          },
          [types.insertNode] = {
            active = {
              hl_mode = 'combine',
              virt_text = { { '●', 'Type' } },
            },
          },
        },
        enable_autosnippets = true,
        snip_env = {
          fmt = fmt,
          m = extras.match,
          t = ls.text_node,
          f = ls.function_node,
          c = ls.choice_node,
          d = ls.dynamic_node,
          i = ls.insert_node,
          l = extras.lamda,
          snippet = ls.snippet,
        },
      })

      ar.command(
        'LuaSnipEdit',
        function() require('luasnip.loaders').edit_snippet_files() end
      )

      -- <c-l> is selecting within a list of options.
      -- vim.keymap.set({ 's', 'i' }, '<c-l>', function()
      --   if ls.choice_active() then ls.change_choice(1) end
      -- end)

      vim.keymap.set({ 's', 'i' }, '<c-l>', function()
        if ls.expand_or_jumpable() then ls.expand_or_jump() end
      end)

      vim.keymap.set({ 's', 'i' }, '<c-b>', function()
        if not ls.jumpable(-1) then return '<S-Tab>' end
        ls.jump(-1)
      end)

      require('luasnip').config.setup({ store_selection_keys = '<C-x>' })

      require('luasnip.loaders.from_lua').lazy_load()
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = {
          join_paths(vim.fn.stdpath('data'), 'lazy', 'friendly-snippets'),
          join_paths(vim.fn.stdpath('config'), 'snippets', 'textmate'),
        },
      })

      ls.filetype_extend('typescriptreact', { 'javascript', 'typescript' })
      ls.filetype_extend('NeogitCommitMessage', { 'gitcommit' })
    end,
  },
  {
    'benfowler/telescope-luasnip.nvim',
    config = function() require('telescope').load_extension('luasnip') end,
  },
}
