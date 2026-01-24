return {
  {
    'mawkler/demicolon.nvim',
    cond = function()
      return ar.get_plugin_cond('demicolon.nvim', ar.treesitter.enable)
    end,
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
    cond = function()
      return ar.get_plugin_cond('repeatable-move.nvim', ar.treesitter.enable)
    end,
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
