return function()
  rvim.project = {
    --- This is on by default since it's currently the expected behavior.
    ---@usage set to false to disable project.nvim.
    active = true,

    -- Manual mode doesn't automatically change your root directory, so you have
    -- the option to manually do so using `:ProjectRoot` command.
    manual_mode = false,

    -- Methods of detecting the root directory. **"lsp"** uses the native neovim
    -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
    -- order matters: if one is not detected, the other is used as fallback. You
    -- can also delete or rearangne the detection methods.
    detection_methods = { "pattern", "lsp" },

    -- All the patterns used to detect root dir, when **"pattern"** is in
    -- detection_methods
    patterns = { ".git", ".hg", ".svn", "Makefile", "package.json", ".luacheckrc", ".stylua.toml" },

    -- Show hidden files in telescope
    show_hidden = false,

    -- When set to false, you will get a message when project.nvim changes your
    -- directory.
    silent_chdir = true,
  }

  local settings = rvim.project

  -- Table of lsp clients to ignore by name
  -- eg: { "efm", ... }
  settings["ignore_lsp"] = {}

  -- Path where project.nvim will store the project history for use in
  -- telescope
  settings["datapath"] = get_cache_dir()

  local status_ok, project = pcall(require, "project_nvim")
  if not status_ok then
    return
  end

  project.setup(settings)
end
