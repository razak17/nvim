local M = {}

function M.setup()
  -- https://observablehq.com/@d3/color-schemes?collection=@d3/d3-scale-chromatic
  -- NOTE: this must be set in the setup function or it will crash nvim...
  require("zephyr.util").plugin("Headlines", {
    Headline1 = { background = "#003c30", foreground = "White" },
    Headline2 = { background = "#00441b", foreground = "White" },
    Headline3 = { background = "#084081", foreground = "White" },
    Dash = { background = "#0b60a1", bold = true },
  })
end

function M.config()
  require("headlines").setup {
    markdown = {
      headline_highlights = { "Headline1", "Headline2", "Headline3" },
    },
  }
end

return M
