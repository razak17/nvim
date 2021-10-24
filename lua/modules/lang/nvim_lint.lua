return function()
  rvim.augroup("AutoLint", {
    {
      events = { "BufWritePost" },
      targets = { "<buffer>" },
      command = ":silent lua require('lint').try_lint()",
    },
    {
      events = { "BufEnter" },
      targets = { "<buffer>" },
      command = ":silent lua require('lint').try_lint()",
    },
  })
end


