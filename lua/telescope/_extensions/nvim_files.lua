local _, builtin = pcall(require, "telescope.builtin")
local _, finders = pcall(require, "telescope.finders")
local _, pickers = pcall(require, "telescope.pickers")
local _, sorters = pcall(require, "telescope.sorters")
local _, themes = pcall(require, "telescope.themes")
local _, actions = pcall(require, "telescope.actions")
local _, previewers = pcall(require, "telescope.previewers")
local _, make_entry = pcall(require, "telescope.make_entry")

local nvim_config = {}
local cwd_git = "~/.dots/rvim"

nvim_config.files = function(opts)
  opts = opts or {}
  local theme_opts = themes.get_ivy {
    sorting_strategy = "ascending",
    layout_strategy = "bottom_pane",
    prompt_prefix = " ❯ ",
    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    layout_config = {
      height = 0.9,
      width = 0.9,
      preview_cutoff = 120,
      horizontal = { mirror = false },
      vertical = { mirror = false },
    },
    prompt_title = "Rvim files",
    cwd = rvim.get_config_dir(),
  }
  opts = vim.tbl_deep_extend("force", theme_opts, opts)
  builtin.find_files(opts)
end

nvim_config.grep_files = function(opts)
  opts = opts or {}
  local theme_opts = themes.get_ivy {
    sorting_strategy = "ascending",
    layout_strategy = "bottom_pane",
    prompt_prefix = " ❯ ",
    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    layout_config = {
      height = 0.9,
      width = 0.9,
      preview_cutoff = 120,
      horizontal = { mirror = false },
      vertical = { mirror = false },
    },
    prompt_title = "Search Rvim",
    cwd = rvim.get_config_dir(),
  }
  opts = vim.tbl_deep_extend("force", theme_opts, opts)
  builtin.live_grep(opts)
end

nvim_config.view_changelog = function()
  local opts = { cwd = rvim.get_config_dir() }
  opts.entry_maker = make_entry.gen_from_git_commits(opts)

  pickers.new(opts, {
    prompt_title = "Rvim changelog",

    finder = finders.new_oneshot_job(
      vim.tbl_flatten {
        "git",
        "log",
        "--pretty=oneline",
        "--abbrev-commit",
      },
      opts
    ),
    previewer = {
      previewers.git_commit_diff_to_parent.new(opts),
      previewers.git_commit_diff_to_head.new(opts),
      previewers.git_commit_diff_as_was.new(opts),
      previewers.git_commit_message.new(opts),
    },

    --TODO: consider opening a diff view when pressing enter
    attach_mappings = function(_, map)
      map("i", "<enter>", actions._close)
      map("n", "<enter>", actions._close)
      map("i", "<esc>", actions._close)
      map("n", "<esc>", actions._close)
      map("n", "q", actions._close)
      return true
    end,
    sorter = sorters.generic_sorter,
  }):find()
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
