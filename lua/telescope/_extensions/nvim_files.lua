local nv_config = {}
local cwd = "~/.dots/nvim"

nv_config.files = function()
  require("telescope.builtin").find_files(
      {prompt_title = "< VimRC >", cwd = "$HOME/.config/nvim/"})
end

nv_config.commits = function()
  require("telescope.builtin").git_commits(
      {prompt_title = 'Git commits for nvim config', cwd = cwd})
end

nv_config.bcommits = function()
  require("telescope.builtin").git_bcommits(
      {prompt_title = 'Git bcommits for nvim config', cwd = cwd})
end

nv_config.branches = function()
  require("telescope.builtin").git_branches(
      {prompt_title = 'Git branches for nvim config', cwd = cwd})
end

nv_config.status = function()
  require("telescope.builtin").git_branches(
      {prompt_title = 'Git status for nvim config', cwd = cwd})
end

return require'telescope'.register_extension {exports = nv_config}

