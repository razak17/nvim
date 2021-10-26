-- vim: ft=lua tw=80
stds.nvim = {
  globals = {
    "rvim",
    "packer_plugins",
    vim = { fields = { "g" } },
    "TERMINAL",
    "USER",
    "C",
    "Config",
    "_GlobalCallbacks",
    "WhichKey",
    "MUtils",
    "fterm_cmd",
    os = { fields = { "capture" } },
  },
  read_globals = {
    "jit",
    "os",
    "vim",
    "join_paths",
    "get_runtime_dir",
    "get_config_dir",
    "get_cache_dir",
    vim = { fields = { "cmd", "api", "fn", "o", "wo", "bo" } },
  },
}
std = "lua51+nvim"

-- Don't report unused self arguments of methods.
self = false

-- Rerun tests only if their modification time changed.
cache = true

ignore = {
  "631", -- max_line_length
  "212/_.*", -- unused argument, for vars with "_" prefix
}
