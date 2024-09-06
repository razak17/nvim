local fn = vim.fn

-- leetcode.nvim
-- https://github.com/kawre/leetcode.nvim
-- You found an easter egg!
-- To use it, uncomment this, exit nvim and write "nvim leetcode.nvim"
return {
  'kawre/leetcode.nvim',
    cond = not ar.plugins.minimal,
  init = function(_, opts)
    if vim.tbl_contains(fn.argv(), 'leetcode.nvim') then
      require('leetcode').setup(opts)
    end
  end,
  build = function()
    -- local cmd = {
    --   'npm',
    --   'install',
    --   '--prefix',
    --   fn.stdpath('data') .. '/site/pack/packer/start/leetcode.nvim',
    --   'typescript',
    --   '@typescript-eslint/eslint-plugin',
    --   '@typescript-eslint/parser',
    -- }
    -- fn.jobstart(
    --   cmd,
    --   { on_exit = function() vim.cmd('packadd leetcode.nvim') end }
    -- )
    fn.jobstart({
      'curl',
      '-o',
      fn.stdpath('data') .. '/leetcode/.eslintrc.json',
      'https://pastebin.com/raw/aQXjpLuE',
    })
  end,
  opts = {
    -- HOW TO ENABLE TYPESCRIPT/JAVASCRIPT LINTING FOR THIS PLUGIN
    -- -----------------------------------------------------------
    -- * Install the eslint packages:
    -- npm install @typescript-eslint/eslint-plugin @typescript-eslint/parser
    -- * Then copy paste this into ~/.local/share/nvim/leetcode/.eslintrc.json
    -- https://pastebin.com/raw/aQXjpLuE
    lang = 'typescript',
  },
}
