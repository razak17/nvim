local M = {
  'L3MON4D3/LuaSnip',
  event = 'InsertEnter',
  dependencies = { 'rafamadriz/friendly-snippets' },
  init = function() rvim.nnoremap('<leader>S', '<cmd>LuaSnipEdit<CR>', 'LuaSnip: edit snippet') end,
}

function M.config()
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

  rvim.command('LuaSnipEdit', function() require('luasnip.loaders').edit_snippet_files() end)

  -- <c-l> is selecting within a list of options.
  vim.keymap.set({ 's', 'i' }, '<c-l>', function()
    if ls.choice_active() then ls.change_choice(1) end
  end)

  vim.keymap.set({ 's', 'i' }, '<c-l>', function()
    if ls.expand_or_jumpable() then ls.expand_or_jump() end
  end)

  vim.keymap.set({ 's', 'i' }, '<c-b>', function()
    if ls.jumpable(-1) then ls.jump(-1) end
  end)

  require('luasnip').config.setup({ store_selection_keys = '<C-x>' })

  local paths = {
    join_paths(rvim.get_runtime_dir(), 'site', 'pack', 'lazy', 'friendly-snippets'),
  }
  local user_snippets = rvim.path.snippets
  if rvim.is_directory(user_snippets) then paths[#paths + 1] = user_snippets end
  require('luasnip.loaders.from_lua').lazy_load()
  require('luasnip.loaders.from_vscode').lazy_load({ paths = paths })
end

return M
