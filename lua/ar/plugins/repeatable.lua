local function get_cond(plugin, variant)
  return function()
    local condition = ar.treesitter.enable
      and ar.config.repeatable.enable
      and ar.config.repeatable.variant == variant
    return ar.get_plugin_cond(plugin, condition)
  end
end

return {
  {
    'mawkler/demicolon.nvim',
    cond = get_cond('demicolon.nvim', 'demicolon'),
    -- stylua: ignore
    init = function()
      map({ 'n', 'x', 'o' }, ';n', function() require('demicolon.repeat_jump').forward() end, { desc = 'demicolon: forward' })
      map({ 'n', 'x', 'o' }, ';p', function() require('demicolon.repeat_jump').backward() end, { desc = 'demicolon: backward' })
    end,
    keys = { ';', ']', '[' },
    dependencies = 'nvim-treesitter/nvim-treesitter-textobjects',
    opts = {
      keymaps = { horizontal_motions = false, repeat_motions = false },
    },
  },
  {
    'kiyoon/repeatable-move.nvim',
    cond = get_cond('repeatable-move.nvim', 'repeatable-move'),
    -- stylua: ignore
    init = function()
      local ok, ts_repeat_move = pcall(require, 'nvim-treesitter-textobjects.repeatable_move')
      if ok then
        map({ 'n', 'x', 'o' }, ';n', ts_repeat_move.repeat_last_move_next, { desc = 'repeatable: forward' })
        map({ 'n', 'x', 'o' }, ';p', ts_repeat_move.repeat_last_move_previous, { desc = 'repeatable: backward' })
      end
    end,
    keys = { ';', ']', '[' },
    dependencies = 'nvim-treesitter/nvim-treesitter-textobjects',
  },
}
