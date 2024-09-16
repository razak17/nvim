local ui, highlight = ar.ui, ar.highlight
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

-- Example for configuring Neovim to load user-installed installed Lua rocks:
local rocks_dir = vim.env.HOME .. '/.luarocks/share/lua/5.1'
package.path = package.path .. ';' .. rocks_dir .. '/?/init.lua;'
package.path = package.path .. ';' .. rocks_dir .. '/?.lua;'

return {
  --------------------------------------------------------------------------------
  -- Markdown
  --------------------------------------------------------------------------------
  {
    'bullets-vim/bullets.vim',
    cond = not minimal,
    ft = { 'markdown' },
  },
  {
    'HakonHarnes/img-clip.nvim',
    cmd = { 'PasteImage' },
    cond = not minimal,
    opts = {},
  },
  {
    '3rd/image.nvim',
    cond = not minimal and not vim.g.neovide,
    ft = { 'markdown' },
    opts = {
      backend = 'kitty',
      -- max_width = 50,
      -- max_height = 50,
      integrations = {
        markdown = {
          only_render_image_at_cursor = true,
        },
      },
    },
  },
  {
    'https://git.sr.ht/~swaits/thethethe.nvim',
    enabled = false,
    cond = not minimal and niceties and false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'Zeioth/markmap.nvim',
    cond = not minimal,
    build = 'yarn global add markmap-cli',
    cmd = { 'MarkmapOpen', 'MarkmapSave', 'MarkmapWatch', 'MarkmapWatchStop' },
    opts = {},
  },
  {
    'OXY2DEV/markview.nvim',
    cond = not minimal and not niceties and false,
    cmd = { 'Markview' },
    ft = { 'markdown' },
    opts = {},
  },
  {
    'arminveres/md-pdf.nvim',
    cond = not minimal,
    keys = {
      {
        '<localleader>mp',
        function() require('md-pdf').convert_md_to_pdf() end,
        desc = 'md-pdf: convert to pdf',
      },
    },
    opts = {},
  },
  {
    'NFrid/due.nvim',
    cond = not minimal,
    ft = 'markdown',
    opts = {
      use_clock_time = true,
      use_clock_today = true,
      use_seconds = false,
    },
    config = function(_, opts) require('due_nvim').setup(opts) end,
  },
  {
    'ellisonleao/glow.nvim',
    cond = not minimal,
    cmd = 'Glow',
    opts = {
      border = 'single',
      width = 120,
    },
  },
  {
    'wallpants/github-preview.nvim',
    cond = not minimal,
    cmd = {
      'GithubPreviewStart',
      'GithubPreviewStop',
      'GithubPreviewToggle',
    },
    opts = {},
  },
  -- https://github.com/AntonVanAssche/md-headers.nvim
  {
    'AntonVanAssche/md-headers.nvim',
    cond = ar.treesitter.enable,
    cmd = { 'MarkdownHeaders', 'MarkdownHeadersClosest' },
    -- stylua: ignore
    keys = {
      { '<localleader>mh', '<cmd>MarkdownHeaders<CR>', desc = 'md-header: headers', },
      { '<localleader>mn', '<cmd>MarkdownHeadersClosest<CR>', desc = 'md-header: closest', },
    },
    opts = { borderchars = ui.border.common },
    config = function(_, opts)
      highlight.plugin('md-headers', {
        theme = {
          ['onedark'] = {
            { MarkdownHeadersBorder = { inherit = 'FloatBorder' } },
            { MarkdownHeadersTitle = { inherit = 'FloatTitle' } },
          },
        },
      })
      require('md-headers').setup(opts)
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cond = not minimal,
    build = function() vim.fn['mkdp#util#install']() end,
    cmd = {
      'MarkdownPreview',
      'MarkdownPreviewStop',
      'MarkdownPreviewToggle',
    },
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    'AckslD/nvim-FeMaco.lua',
    cond = not minimal,
    cmd = { 'FeMaco' },
    opts = {
      float_opts = function(code_block)
        local clip_val = require('femaco.utils').clip_val
        return {
          relative = 'cursor',
          width = clip_val(5, 120, vim.api.nvim_win_get_width(0) - 10),
          height = clip_val(
            5,
            #code_block.lines,
            vim.api.nvim_win_get_height(0) - 6
          ),
          anchor = 'NW',
          row = 0,
          col = 0,
          style = 'minimal',
          border = ui.current.border,
          zindex = 1,
        }
      end,
    },
  },
  {
    'nfrid/markdown-togglecheck',
    -- stylua: ignore
    keys = {
      { '<leader>om', function() require('markdown-togglecheck').toggle() end, desc = 'toggle markdown checkbox', },
    },
    dependencies = { 'nfrid/treesitter-utils' },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    cond = not minimal,
    cmd = { 'RenderMarkdownToggle' },
    ft = { 'markdown', 'Avante' },
    init = function()
      local color1_bg = '#f265b5'
      local color2_bg = '#37f499'
      local color3_bg = '#04d1f9'
      local color4_bg = '#a48cf2'
      local color5_bg = '#f1fc79'
      local color6_bg = '#f7c67f'
      local color_fg = '#323449'

      highlight.plugin('render-markdown', {
        theme = {
          ['onedark'] = {
            { MarkdownCodeBlock = { link = 'CodeBlock' } },
            -- Heading colors (when not hovered over), extends through the entire line
            { Headline1Bg = { fg = color_fg, bg = color1_bg } },
            { Headline2Bg = { fg = color_fg, bg = color2_bg } },
            { Headline3Bg = { fg = color_fg, bg = color3_bg } },
            { Headline4Bg = { fg = color_fg, bg = color4_bg } },
            { Headline5Bg = { fg = color_fg, bg = color5_bg } },
            { Headline6Bg = { fg = color_fg, bg = color6_bg } },
            -- Highlight for the heading and sign icons (symbol on the left)
            -- I have the sign disabled for now, so this makes no effect
            { Headline1Fg = { fg = color1_bg, cterm = 'bold', gui = 'bold' } },
            { Headline2Fg = { fg = color2_bg, cterm = 'bold', gui = 'bold' } },
            { Headline3Fg = { fg = color3_bg, cterm = 'bold', gui = 'bold' } },
            { Headline4Fg = { fg = color4_bg, cterm = 'bold', gui = 'bold' } },
            { Headline5Fg = { fg = color5_bg, cterm = 'bold', gui = 'bold' } },
            { Headline6Fg = { fg = color6_bg, cterm = 'bold', gui = 'bold' } },
          },
        },
      })
    end,
    opts = {
      file_types = { 'markdown', 'Avante' },
      heading = {
        sign = false,
        -- signs = { '󰫎 ' },
        enabled = not ar.treesitter.enable,
        icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
        backgrounds = {
          'Headline1Bg',
          'Headline2Bg',
          'Headline3Bg',
          'Headline4Bg',
          'Headline5Bg',
          'Headline6Bg',
        },
        foregrounds = {
          'Headline1Fg',
          'Headline2Fg',
          'Headline3Fg',
          'Headline4Fg',
          'Headline5Fg',
          'Headline6Fg',
        },
      },
      checkbox = {
        enabled = true,
		    position = "overlay",
        unchecked = {
          icon = '', -- 🔲
          highlight = '@markup.list.unchecked',
        },
        checked = {
          icon = '', -- ✅
          highlight = '@markup.heading',
        },
      },
      bullet = {
        enabled = true,
        icons = { '▶', '○', '●', '▷' }, --  '◆', '◇'
        highlight = 'Directory',
      },
      code = {
        enabled = true,
        style = 'normal',
        highlight = 'ColorColumn',
      },
    },
  },
}
