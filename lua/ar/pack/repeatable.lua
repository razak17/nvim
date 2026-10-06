local coding = ar.plugins.coding

local function get_cond(plugin, variant)
  local condition = coding
    and ar.treesitter.enable
    and ar.config.repeatable.enable
    and ar.config.repeatable.variant == variant
  return ar.get_plugin_cond(plugin, condition)
end

if get_cond('demicolon.nvim', 'demicolon') then
  vim.pack.add({
    'https://github.com/mawkler/demicolon.nvim',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  }, { confirm = false })

  require('demicolon').setup({
    keymaps = { horizontal_motions = false, repeat_motions = false },
  })

  -- stylua: ignore start
  map({ 'n', 'x', 'o' }, ';n', function() require('demicolon.repeat_jump').forward() end, { desc = 'demicolon: forward' })
  map({ 'n', 'x', 'o' }, ';p', function() require('demicolon.repeat_jump').backward() end, { desc = 'demicolon: backward' })
  -- stylua: ignore end
end

if get_cond('repeatable-move.nvim', 'repeatable-move') then
  vim.pack.add({
    'https://github.com/kiyoon/repeatable-move.nvim',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  }, { confirm = false })

  require('repeatable_move')
  local ts_repeat_move = require('nvim-treesitter-textobjects.repeatable_move')

  -- stylua: ignore start
  map({ 'n', 'x', 'o' }, ';n', ts_repeat_move.repeat_last_move_next, { desc = 'repeatable: forward' })
  map({ 'n', 'x', 'o' }, ';p', ts_repeat_move.repeat_last_move_previous, { desc = 'repeatable: backward' })
  map({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
  map({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
  map({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
  map({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })
  -- stylua: ignore end
end
