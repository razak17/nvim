-- vim: ft=lua tw=80

stds.nvim = {
  globals = {
    "rvim",
    "packer_plugins",
    vim = { fields = { "g" } },
    "TERMINAL",
    "USER",
    "C",
    "_GlobalCallbacks",
    "WhichKey",
    "MUtils",
    os = { fields = { "capture" } },
  },
  read_globals = {
    "jit",
    "os",
    "vim",
    "join_paths",
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
