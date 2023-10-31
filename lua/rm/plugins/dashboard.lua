local fmt = string.format

return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  keys = { { '<leader>;', '<cmd>Alpha<CR>', desc = 'alpha' } },
  config = function()
    local alpha = require('alpha')
    local dashboard = require('alpha.themes.dashboard')
    local fortune = require('alpha.fortune')

    local button = function(h, ...)
      local btn = dashboard.button(...)
      local details = select(2, ...)
      local icon = details:match('[^%w%s]+') -- match non alphanumeric or space characters
      btn.opts.hl = { { h, 0, #icon + 1 } } -- add one space padding
      btn.opts.hl_shortcut = 'Title'
      return btn
    end

    rvim.highlight.plugin('alpha', {
      { StartLogo1 = { fg = '#1C506B' } },
      { StartLogo2 = { fg = '#1D5D68' } },
      { StartLogo3 = { fg = '#1E6965' } },
      { StartLogo4 = { fg = '#1F7562' } },
      { StartLogo5 = { fg = '#21825F' } },
      { StartLogo6 = { fg = '#228E5C' } },
      { StartLogo7 = { fg = '#239B59' } },
      { StartLogo8 = { fg = '#24A755' } },
      -- { StartLogo9 = { fg = '#25B151' } },
      -- { StartLogo10 = { fg = '#26B747' } },
      -- { StartLogo11 = { fg = '#26B747' } },
      -- { StartLogo12 = { fg = '#26B747' } },
    })

    local header = {
      [[                                                                   ]],
      [[      ████ ██████           █████      ██                    ]],
      [[     ███████████             █████                            ]],
      [[     █████████ ███████████████████ ███   ███████████  ]],
      [[    █████████  ███    █████████████ █████ ██████████████  ]],
      [[   █████████ ██████████ █████████ █████ █████ ████ █████  ]],
      [[ ███████████ ███    ███ █████████ █████ █████ ████ █████ ]],
      [[██████  █████████████████████ ████ █████ █████ ████ ██████]],
      -- [[⠀⠀⠀⠀⣀⣀⣤⣤⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⡄⠀⠀⠀⠀⠀⠀⠀]],
      -- [[⠀⠀⠀⠀⣿⣿⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠛⠛⢿⣿⡇⠀⠀⠀⠀⠀⠀⠀]],
      -- [[⠀⠀⠀⠀⣿⡟⠡⠂⠀⢹⣿⣿⣿⣿⣿⣿⡇⠘⠁⠀⠀⣿⡇⠀⢠⣄⠀⠀⠀⠀]],
      -- [[⠀⠀⠀⠀⢸⣗⢴⣶⣷⣷⣿⣿⣿⣿⣿⣿⣷⣤⣤⣤⣴⣿⣗⣄⣼⣷⣶⡄⠀⠀]],
      -- [[⠀⠀⠀⢀⣾⣿⡅⠐⣶⣦⣶⠀⢰⣶⣴⣦⣦⣶⠴⠀⢠⣿⣿⣿⣿⣿⣿⡇⠀⠀]],
      -- [[⠀⠀⢀⣾⣿⣿⣷⣬⡛⠷⣿⣿⣿⣿⣿⣿⣿⠿⠿⣠⣿⣿⣿⣿⣿⠿⠛⠀⠀⠀]],
      -- [[⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣶⣦⣭⣭⣥⣭⣵⣶⣿⣿⣿⣿⡟⠉⠀⠀⠀⠀⠀⠀]],
      -- [[⠀⠀⠀⠙⠇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀]],
      -- [[⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣛⠛⠛⠛⠛⠛⢛⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀]],
      -- [[⠀⠀⠀⠀⠀⠿⣿⣿⣿⠿⠿⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⠿⠇⠀  ⠀⠀⠀⠀]],
    }

    -- Make the header a bit more fun with some color!
    local function neovim_header()
      return vim
        .iter(ipairs(header))
        :map(
          function(i, chars)
            return {
              type = 'text',
              val = chars,
              opts = {
                hl = 'StartLogo' .. i,
                shrink_margin = false,
                position = 'center',
              },
            }
          end
        )
        :totable()
    end

    local stats = require('lazy').stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

    local installed_plugins = {
      type = 'text',
      val = fmt(
        ' %s plugins loaded in %s',
        stats.loaded .. ' of ' .. stats.count,
        ms .. 'ms'
      ),
      opts = { position = 'center', hl = 'GitSignsAdd' },
    }

    local v = vim.version()
    local version = {
      type = 'text',
      val = fmt(
        'Neovim v%d.%d.%d %s',
        v.major,
        v.minor,
        v.patch,
        v.prerelease and '(nightly)' or ''
      ),
      opts = { position = 'center', hl = 'NonText' },
    }

    dashboard.section.buttons.val = {
      button('Directory', 'r', '  Restore session', '<Cmd>SessionLoad<CR>'),
      button('Todo', 's', '󰋇  Pick a session', '<Cmd>ListSessions<CR>'),
      button(
        'Directory',
        'p',
        '  Recent projects',
        '<Cmd>Telescope projects<CR>'
      ),
      button('String', 'f', '  Find file', '<Cmd>FzfLua files<CR>'),
      button('Define', 'w', '󰈭  Find text', '<Cmd>FzfLua live_grep<CR>'),
      -- button('Keyword', 'n', '  New file', ':ene | startinsert<CR>'),
      button('Ignore', 'l', '󰒲  Lazy', '<Cmd>Lazy<CR>'),
      button('ErrorMsg', 'q', '  Quit', '<cmd> qa <cr>'),
    }

    dashboard.section.footer.val = fortune()
    dashboard.section.footer.opts.hl = 'TSEmphasis'

    alpha.setup({
      layout = {
        { type = 'padding', val = 4 },
        { type = 'group', val = neovim_header() },
        { type = 'padding', val = 1 },
        installed_plugins,
        { type = 'padding', val = 2 },
        dashboard.section.buttons,
        dashboard.section.footer,
        { type = 'padding', val = 2 },
        version,
      },
      opts = { margin = 5 },
    })
  end,
}
