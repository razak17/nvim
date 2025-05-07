local ui, highlight = ar.ui, ar.highlight
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

-- Example for configuring Neovim to load user-installed installed Lua rocks:
local rocks_dir = vim.env.HOME .. '/.luarocks/share/lua/5.1'
if vim.env.ASDF_DIR then
  rocks_dir = vim.env.ASDF_DIR .. '/installs/lua/5.1/luarocks/share/lua/5.1'
end
package.path = package.path .. ';' .. rocks_dir .. '/?/init.lua;'
package.path = package.path .. ';' .. rocks_dir .. '/?.lua;'

return {
  --------------------------------------------------------------------------------
  -- Markdown
  --------------------------------------------------------------------------------
  {
    'sotte/presenting.nvim',
    opts = {},
    cmd = { 'Presenting' },
  },
  {
    'bullets-vim/bullets.vim',
    cond = not minimal,
    ft = { 'markdown' },
    init = function()
      vim.g.bullets_set_mappings = 0
      vim.g.bullets_custom_mappings = {
        -- { 'imap', '<cr>', '<Plug>(bullets-newline)' },
        -- { 'inoremap', '<C-cr>', '<cr>' },
        { 'nmap', 'o', '<Plug>(bullets-newline)' },
        { 'vmap', 'gN', '<Plug>(bullets-renumber)' },
        { 'nmap', 'gN', '<Plug>(bullets-renumber)' },
        { 'nmap', '<leader>ox', '<Plug>(bullets-toggle-checkbox)' },
        { 'imap', '<C-t>', '<Plug>(bullets-demote)' },
        { 'nmap', '>>', '<Plug>(bullets-demote)' },
        { 'vmap', '>', '<Plug>(bullets-demote)' },
        { 'imap', '<C-d>', '<Plug>(bullets-promote)' },
        { 'nmap', '<<', '<Plug>(bullets-promote)' },
        { 'vmap', '<', '<Plug>(bullets-promote)' },
      }

      ar.augroup('BulletsMappings', {
        event = 'FileType',
        pattern = { 'markdown' },
        command = function(args)
          map('i', '<cr>', '<Plug>(bullets-newline)', { buffer = args.buf })
          map('i', '<C-cr>', '<cr>', { buffer = args.buf })
        end,
      })
    end,
  },
  {
    'HakonHarnes/img-clip.nvim',
    cmd = { 'PasteImage' },
    cond = not minimal,
    opts = {},
  },
  {
    '3rd/image.nvim',
    cond = false
      and not minimal
      and not vim.g.neovide
      and not ar.kitty_scrollback.enable,
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
    'Zeioth/markmap.nvim',
    cond = not minimal,
    build = 'yarn global add markmap-cli',
    cmd = { 'MarkmapOpen', 'MarkmapSave', 'MarkmapWatch', 'MarkmapWatchStop' },
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
    cond = ar.ts_extra_enabled,
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
    cmd = { 'RenderMarkdown' },
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
        -- stylua: ignore
        theme = {
          ['onedark'] = {
            { MarkdownCodeBlock = { link = 'CodeBlock' } },
            -- Heading colors (when not hovered over), extends through the entire line
            { RenderMarkdownH1Bg = { fg = color_fg, bg = color1_bg } },
            { RenderMarkdownH2Bg = { fg = color_fg, bg = color2_bg } },
            { RenderMarkdownH3Bg = { fg = color_fg, bg = color3_bg } },
            { RenderMarkdownH4Bg = { fg = color_fg, bg = color4_bg } },
            { RenderMarkdownH5Bg = { fg = color_fg, bg = color5_bg } },
            { RenderMarkdownH6Bg = { fg = color_fg, bg = color6_bg } },
            -- Highlight for the heading and sign icons (symbol on the left)
            -- I have the sign disabled for now, so this makes no effect
            { RenderMarkdownH1 = { fg = color1_bg, cterm = 'bold', gui = 'bold' } },
            { RenderMarkdownH2 = { fg = color2_bg, cterm = 'bold', gui = 'bold' } },
            { RenderMarkdownH3 = { fg = color3_bg, cterm = 'bold', gui = 'bold' } },
            { RenderMarkdownH4 = { fg = color4_bg, cterm = 'bold', gui = 'bold' } },
            { RenderMarkdownH5 = { fg = color5_bg, cterm = 'bold', gui = 'bold' } },
            { RenderMarkdownH6 = { fg = color6_bg, cterm = 'bold', gui = 'bold' } },
          },
        },
      })

      ar.add_to_select_menu('command_palette', {
        ['RenderMarkdown Toggle'] = 'RenderMarkdown toggle',
      })
    end,
    opts = {
      completions = {
        blink = { enabled = ar_config.completion.variant == 'blink' },
        lsp = { enabled = ar.lsp.enable },
      },
      file_types = { 'markdown', 'Avante' },
      heading = {
        enabled = not ar.ts_extra_enabled,
        sign = false, --  { '󰫎 ' }
        icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
      },
      checkbox = {
        enabled = true,
        position = 'inline',
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
        sign = false,
        style = 'normal', -- 'normal' | 'full' | 'language' | 'thick'
        highlight = 'NormalFloat',
        language_icon = true,
        language_name = true,
      },
    },
  },
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'https://git.sr.ht/~swaits/thethethe.nvim',
    enabled = false,
    cond = not minimal and niceties and false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'OXY2DEV/markview.nvim',
    cond = not minimal and not niceties and false,
    cmd = { 'Markview' },
    ft = { 'markdown' },
    opts = {},
    init = function()
      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle Markview'] = 'Markview' }
      )
    end,
  },
}
