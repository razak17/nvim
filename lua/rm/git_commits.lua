if not rvim or not rvim.plugins.enable then return end

local utils = require('rm.utils')

local M = {}

function M.display_commit_from_hash()
  vim.ui.input(
    { prompt = 'Enter git commit id:', kind = 'center_win' },
    function(input)
      if input ~= nil then
        vim.cmd(':DiffviewOpen ' .. input .. '^..' .. input)
      end
    end
  )
end

local opts = {
  attach_mappings = utils.telescope_commits_mappings,
  entry_maker = utils.custom_make_entry_gen_from_git_commits(),
  git_command = {
    'git',
    'log',
    '--pretty=tformat:%<(10)%h%<(16,trunc)%an %ad%d %s',
    '--date=short',
    '--',
    '.',
  },
  layout_config = { width = 0.9, horizontal = { preview_width = 0.5 } },
  previewer = rvim.telescope.delta_opts().previewer,
}

function M.browse_commits() require('telescope.builtin').git_commits(opts) end

function M.browse_bcommits() require('telescope.builtin').git_bcommits(opts) end

return M
