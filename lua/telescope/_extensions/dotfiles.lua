local finders = require('telescope.finders')
local builtin = require('telescope.builtin')
local utils = require('telescope.utils')
local dots_config = {}
local cwd = "~/.dots/dotfiles"

dots_config.git_files = function(opts)
  local show_untracked = utils.get_default(opts.show_untracked, true)
  local recurse_submodules = utils.get_default(opts.recurse_submodules, false)
  builtin.git_files({
    prompt_title = "Find in dotfiles",
    cwd = cwd,
    finder = finders.new_oneshot_job(vim.tbl_flatten(
                                         {
          "git",
          "--git-dir=/home/razak/.dots/dotfiles/",
          "--work-tree=/home/razak/.config/dotfiles",
          "ls-files",
          "--exclude-standard",
          "--cached",
          show_untracked and "--others" or nil,
          recurse_submodules and "--recurse-submodules" or nil
        }), opts)
  })
end

dots_config.commits = function()
  builtin.git_commits({prompt_title = 'Git commits for dotfiles', cwd = cwd})
end

dots_config.bcommits = function()
  builtin.git_bcommits({prompt_title = 'Git bcommits For dotfiles', cwd = cwd})
end

dots_config.branches = function()
  builtin.git_branches({prompt_title = 'Git branches for dotfiles', cwd = cwd})
end

dots_config.status = function()
  builtin.git_status({prompt_title = 'Git status for dotfiles', cwd = cwd})
end

return require'telescope'.register_extension {exports = dots_config}

