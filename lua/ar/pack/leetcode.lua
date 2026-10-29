ar.pack.add({
  src = 'https://github.com/kawre/leetcode.nvim',
  cond = function()
    return ar.get_plugin_cond('leetcode.nvim', not ar.plugins.minimal)
  end,
  -- setup registers the VimEnter handler for `nvim leetcode.nvim`.
  lazy = false,
  dependencies = {
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/MunifTanjim/nui.nvim' },
  },
  build = function()
    local directory = vim.fn.stdpath('data') .. '/leetcode'
    vim.fn.mkdir(directory, 'p')
    local result = vim
      .system({
        'curl',
        '--fail',
        '--location',
        '-o',
        directory .. '/.eslintrc.json',
        'https://pastebin.com/raw/aQXjpLuE',
      }, { text = true })
      :wait()
    assert(result.code == 0, result.stderr)
  end,
  setup = function() require('leetcode').setup({ lang = 'typescript' }) end,
})
