if not ar.has('snacks.nvim') then return end

local border = ar.ui.current.border.default

ar.snacks_opts = vim.tbl_deep_extend('force', ar.snacks_opts or {}, {
  styles = vim.tbl_deep_extend('force', ar.snacks_opts.styles or {}, {
    blame_line = { border = border },
    git = { border = border },
    lazygit = { border = border },
  }),
  git = { enabled = true },
  gitbrowse = { enabled = true },
})

-- stylua: ignore start
map('n', '<leader>gbb', function() Snacks.git.blame_line() end, { desc = 'snacks: git blame line' })
map('n', '<leader>goo', function() Snacks.gitbrowse() end, { desc = 'snacks: open current line' })
map('n', '<leader>gD', function() Snacks.picker.git_diff({ base = 'origin', group = true }) end, { desc = 'snacks: git diff (origin)' })
map('n', '<leader>gi', function() Snacks.picker.gh_issue() end, { desc = 'snacks: github issues (open)' })
map('n', '<leader>gI', function() Snacks.picker.gh_issue({ state = 'all' }) end, { desc = 'snacks: github issues (all)' })
map('n', '<leader>gp', function() Snacks.picker.gh_pr() end, { desc = 'snacks: gitHub pull requests (open)' })
map('n', '<leader>gP', function() Snacks.picker.gh_pr({ state = 'all' }) end, { desc = 'GitHub Pull Requests' })
map('n', '<leader>gh', function() Snacks.lazygit.log_file() end, { desc = 'snacks: log (file)' })
map('n', '<leader>gH', function() Snacks.lazygit.log() end, { desc = 'snacks: log (cwd)' })
-- stylua: ignore end
