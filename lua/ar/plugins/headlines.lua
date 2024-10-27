return {
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'lukas-reineke/headlines.nvim',
    enabled = false,
    cond = not ar.plugins.minimal and ar.plugins.niceties,
    ft = { 'org', 'norg', 'markdown', 'yaml' },
    opts = {
      org = { headline_highlights = false },
      norg = {
        headline_highlights = { 'Headline' },
        codeblock_highlight = false,
      },
      markdown = {
        -- If set to false, headlines will be a single line and there will be no
        -- "fat_headline_upper_string" and no "fat_headline_lower_string"
        fat_headlines = true,
        --
        -- Lines added above and below the header line makes it look thicker
        -- "lower half block" unicode symbol hex:2584
        -- "upper half block" unicode symbol hex:2580
        fat_headline_upper_string = '▄',
        fat_headline_lower_string = '▀',
        --
        -- You could add a full block if you really like it thick ;)
        -- fat_headline_upper_string = "█",
        -- fat_headline_lower_string = "█",
        --
        -- Other set of lower and upper symbols to try
        -- fat_headline_upper_string = "▃",
        -- fat_headline_lower_string = "-",
        --
        headline_highlights = {
          'Headline1',
          'Headline2',
          'Headline3',
          'Headline4',
          'Headline5',
          'Headline6',
        },
        bullets = { '󰎤', '󰎧', '󰎪', '󰎭', '󰎱', '󰎳' },
      },
    },
    config = function(_, opts)
      local color1_bg = '#f265b5'
      local color2_bg = '#37f499'
      local color3_bg = '#04d1f9'
      local color4_bg = '#a48cf2'
      local color5_bg = '#f1fc79'
      local color6_bg = '#f7c67f'
      local color_fg = 'white'
      -- local color_fg = '#323449'
      -- local color_block = '#09090d'

      -- Define custom highlight groups using Vimscript
      ar.highlight.plugin('render-markdown', {
        theme = {
          ['onedark'] = {
            { Headline1 = { fg = color_fg, bg = color1_bg } },
            { Headline2 = { fg = color_fg, bg = color2_bg } },
            { Headline3 = { fg = color_fg, bg = color3_bg } },
            { Headline4 = { fg = color_fg, bg = color4_bg } },
            { Headline5 = { fg = color_fg, bg = color5_bg } },
            { Headline6 = { fg = color_fg, bg = color6_bg } },
            -- { CodeBlock = { bg = color_block } },
            -- { Dash = { fg = color_fg } },
          },
        },
      })

      -- PERF: schedule to prevent headlines slowing down opening a file
      vim.schedule(function()
        require('headlines').setup(opts)
        require('headlines').refresh()
      end)
    end,
  },
}
