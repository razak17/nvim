local border = ar.ui.current.border.default

return {
  desc = 'snacks git',
  recommended = true,
  'folke/snacks.nvim',
  keys = function(_, keys)
    keys = keys or {}
    -- stylua: ignore
    local git_mappings = {
      { '<leader>gbb', function() Snacks.git.blame_line() end, desc = 'snacks: git blame line' },
      { '<leader>goo', function() Snacks.gitbrowse() end, desc = 'snacks: open current line' },
      { '<leader>gD', function() Snacks.picker.git_diff({ base = 'origin', group = true }) end, desc = 'snacks: git diff (origin)' },
      { '<leader>gi', function() Snacks.picker.gh_issue() end, desc = 'snacks: github issues (open)' },
      { '<leader>gI', function() Snacks.picker.gh_issue({ state = 'all' }) end, desc = 'snacks: github issues (all)' },
      { '<leader>gp', function() Snacks.picker.gh_pr() end, desc = 'snacks: gitHub pull requests (open)' },
      { '<leader>gP', function() Snacks.picker.gh_pr({ state = 'all' }) end, desc = 'GitHub Pull Requests' },
      { '<leader>gh', function() Snacks.lazygit.log_file() end, desc = 'snacks: log (file)' },
      { '<leader>gH', function() Snacks.lazygit.log() end, desc = 'snacks: log (cwd)' },
    }
    vim.iter(git_mappings):each(function(m) table.insert(keys, m) end)
  end,
  opts = function(_, opts)
    return vim.tbl_deep_extend('force', opts or {}, {
      styles = vim.tbl_deep_extend('force', opts.styles or {}, {
        blame_line = { border = border },
        git = { border = border },
        lazygit = { border = border },
      }),
      git = { enabled = true },
      gitbrowse = { enabled = true },
    })
  end,
}
