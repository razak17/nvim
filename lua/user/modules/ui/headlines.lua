local M = { 'lukas-reineke/headlines.nvim', ft = { 'org', 'norg', 'markdown', 'yaml' } }

function M.init()
  require('user.utils.highlights').plugin('Headlines', {
    { Headline1 = { background = '#003c30', foreground = 'White' } },
    { Headline2 = { background = '#00441b', foreground = 'White' } },
    { Headline3 = { background = '#084081', foreground = 'White' } },
    { Dash = { background = '#0b60a1', bold = true } },
  })
end

function M.config()
  require('headlines').setup({
    markdown = {
      headline_highlights = { 'Headline1', 'Headline2', 'Headline3' },
    },
    org = { headline_highlights = false },
    norg = { codeblock_highlight = false },
  })
end

return M
