local builtin = require "telescope.builtin"
local nvim_config = {}
local cwd_git = "~/.dots/rvim"

nvim_config.git_files = function()
  builtin.git_files { prompt_title = "Git files for nvim config", cwd = cwd_git }
end

nvim_config.files = function()
  builtin.find_files { prompt_title = "< VimRC >", cwd = get_config_dir() }
end

nvim_config.commits = function()
  builtin.git_commits { prompt_title = "Git commits for nvim config", cwd = cwd_git }
end

nvim_config.bcommits = function()
  builtin.git_bcommits {
    prompt_title = "Git bcommits for nvim config",
    cwd = cwd_git,
  }
end

nvim_config.branches = function()
  builtin.git_branches {
    prompt_title = "Git branches for nvim config",
    cwd = cwd_git,
  }
end

nvim_config.status = function()
  builtin.git_status { prompt_title = "Git status for nvim config", cwd = cwd_git }
end

return require("telescope").register_extension { exports = nvim_config }
