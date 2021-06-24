local builtin = require('telescope.builtin')
local dots_config = {}
local cwd = "~/.dots/dotfiles"

dots_config.git_files = function()
  builtin.git_files({prompt_title = "Git files for dotfiles", cwd = cwd})
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

-- return require'telescope'.register_extension {exports = dots_config}

