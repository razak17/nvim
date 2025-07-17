local fn = vim.fn
local minimal = ar.plugins.minimal

local function expand_or_jump()
  local ls = require('luasnip')
  if ls.expand_or_locally_jumpable() then
    vim.schedule(function() ls.expand_or_jump(1) end)
    return true
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<c-i>', true, false, true),
      'n',
      false
    )
  end
end

local function jump_prev()
  local ls = require('luasnip')
  if ls.jumpable(-1) then
    vim.schedule(function() ls.jump(-1) end)
    return true
  end
end

local function change_choice()
  local ls = require('luasnip')
  if ls.choice_active() then
    vim.schedule(function() ls.change_choice(1) end)
    return true
  end
end

local function get_snippets_list()
  local modules_dir = join_paths(fn.stdpath('config'), 'lua', 'ar', 'snippets')
  local tmp = vim.split(fn.globpath(modules_dir, '*.lua'), '\n')
  return vim
    .iter(tmp)
    :map(function(f) return string.match(f, 'lua/(.+).lua$') end)
    :totable()
end

return {
  { 'rafamadriz/friendly-snippets', cond = not minimal },
  {
    's1n7ax/nvim-snips',
    name = 'snips',
    dependencies = { 'razak17/nvim-ts-utils' },
  },
  {
    'L3MON4D3/LuaSnip',
    cond = not minimal,
    event = 'InsertEnter',
    build = 'make install_jsregexp',
    -- stylua: ignore
    keys = {
      { '<leader>S', function() require('luasnip.loaders').edit_snippet_files() end, desc = 'LuaSnip: edit snippet' },
      { '<C-l>', expand_or_jump, desc = 'LuaSnip: expand or jump', mode = { 'i', 's' } },
			{ '<C-b>', jump_prev, desc = 'LuaSnip: jump prev', mode = { 's' } },
			{ '<C-/>', change_choice, desc = 'LuaSnip: change choice', mode = { 'i', 's' } },
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

      require('luasnip').config.setup({ store_selection_keys = '<C-x>' })

      require('luasnip.loaders.from_lua').lazy_load()
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = {
          join_paths(fn.stdpath('data'), 'lazy', 'friendly-snippets'),
          join_paths(fn.stdpath('config'), 'snippets', 'textmate'),
        },
      })

      ls.filetype_extend('typescriptreact', { 'javascript', 'typescript' })
      ls.filetype_extend('NeogitCommitMessage', { 'gitcommit' })

      if ar.treesitter.enable and ar.is_available('snips') then
        local snippets_list = get_snippets_list()
        for _, module_path in ipairs(snippets_list) do
          local ok, snip = pcall(require, module_path)
          if ok then snip.setup() end
        end
      end
    end,
  },
  {
    'benfowler/telescope-luasnip.nvim',
    cond = not ar.plugins.minimal,
    config = function() require('telescope').load_extension('luasnip') end,
  },
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'garymjr/nvim-snippets',
    enabled = false,
    cond = ar.completion.enable and false,
    event = 'InsertEnter',
    opts = {
      friendly_snippets = true,
      extended_filetypes = {
        typescript = { 'javascript', 'javascriptreact', 'jsdoc' },
        typescriptreact = { 'javascript', 'javascriptreact', 'jsdoc' },
      },
      search_paths = {
        join_paths(fn.stdpath('config'), 'snippets', 'textmate'),
        -- join_paths(fn.stdpath('data'), 'lazy', 'friendly-snippets'),
      },
    },
    dependencies = { 'rafamadriz/friendly-snippets' },
  },
}
