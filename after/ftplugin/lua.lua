if not ar or ar.none then return end

local opt = vim.opt_local

opt.textwidth = 80
opt.spell = true

if not ar.plugins.enable or ar.plugins.minimal then return end

opt.spellfile:prepend(
  join_paths(vim.fn.stdpath('config'), 'spell', 'lua.utf-8.add')
)
opt.spelllang = { 'en_gb', 'programming' }

local is_available = ar.is_available

if
  is_available('LuaSnip')
  and is_available('nvim-treesitter')
  and is_available('snips.lua')
then
  -- https://github.com/s1n7ax/lazyvim-dotnvim/blob/main/lua/plugins/luasnip/snippets/lua.lua
  local ls = require('luasnip')
  local s = ls.s
  local lua = require('snips.lua')
  local common = require('snips.common')
  local postfix = require('luasnip.extras.postfix').postfix

  ls.add_snippets('lua', {
    -- postfix
    postfix({
      trig = '.v',
      match_pattern = '[%w%.%_%-%(%)]+$',
    }, lua.postfix.variable()),
    postfix({
      trig = '.r',
      match_pattern = '[%w%.%_%-%(%)]+$',
    }, lua.postfix.returns()),

    -- choice & dynamic
    s('f', lua.choices.func()),
    s('fd', lua.choices.func_with_doc()),
    s('mod', lua.choices.module()),
    s('v', lua.dynamic.variable()),

    -- primitives
    s('faa', lua.primitives.anonymous_func()),
    s('fa', lua.primitives.noarg_anonymous_func()),
    s('i', lua.primitives.import()),
    s('o', lua.primitives.stdout()),
    s('r', common.primitives.returns()),
    s('oo', lua.primitives.pretty_print()),
    s('td', lua.primitives.test_desc()),
    s('ti', lua.primitives.test_it()),
  })
end
