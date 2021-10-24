return function()
  rvim.augroup("user_plugin_cursorword", {
    {
      events = { "FileType" },
      targets = {
        "NvimTree",
        "lspsagafinder",
        "dashboard",
        "outline",
        "telescope",
        "lspinfo",
        "help",
        "fTerm",
        "TelescopePrompt",
        "qf",
        "packer",
        "log",
        "slide",
        "", -- for all buffers without a file type
      },
      command = "let b:cursorword = 0",
    },
    { events = { "TermOpen" }, targets = { "*:zsh" }, command = "let b:cursorword = 0" },
    {
      events = { "WinEnter" },
      targets = { "*" },
      command = [[if &diff || &pvw | let b:cursorword = 0  | endif]],
    },
    { events = { "InsertEnter" }, targets = { "*" }, command = "let b:cursorword = 0" },
    { events = { "InsertLeave" }, targets = { "*" }, command = "let b:cursorword = 1" },
  })
end

