local fmt = string.format
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'goolord/alpha-nvim',
    cond = not minimal
      and ar_config.dashboard.enable
      and ar_config.dashboard.variant == 'alpha',
    event = 'VimEnter',
    keys = { { '<leader>;', '<cmd>Alpha<CR>', desc = 'alpha' } },
    opts = function()
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

      ar.highlight.plugin('alpha', {
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
        -- [[             ,.,   '           ,. -  .,                  ,.-.                        ,.-·.         ,·'´¨;.  '                        ]],
        -- [[           ;´   '· .,        ,' ,. -  .,  `' ·,          /   ';\ '                    /    ;'\'       ;   ';:\           .·´¨';\     ]],
        -- [[         .´  .-,    ';\      '; '·~;:::::'`,   ';\      ';    ;:'\      ,·'´';        ;    ;:::\     ;     ';:'\      .'´     ;:'\   ]],
        -- [[        /   /:\:';   ;:'\'     ;   ,':\::;:´  .·´::\'     ';   ;::;     ,'  ,''\      ';    ;::::;'    ;   ,  '·:;  .·´,.´';  ,'::;' ]],
        -- [[      ,'  ,'::::'\';  ;::';     ;  ·'-·'´,.-·'´:::::::';    ';   ';::;   ,'  ,':::'\'     ;   ;::::;    ;   ;'`.    ¨,.·´::;'  ;:::; ]],
        -- [[  ,.-·'  '·~^*'´¨,  ';::;   ;´    ':,´:::::::::::·´'      ';   ;:;  ,'  ,':::::;'    ';  ;'::::;     ;  ';::; \*´\:::::;  ,':::;‘    ]],
        -- [[  ':,  ,·:²*´¨¯'`;  ;::';    ';  ,    `·:;:-·'´            ;   ;:;'´ ,'::::::;'  '   ;  ';:::';     ';  ,'::;   \::\;:·';  ;:::; '   ]],
        -- [[  ,'  / \::::::::';  ;::';    ; ,':\'`:·.,  ` ·.,           ';   '´ ,·':::::;'        ';  ;::::;'    ;  ';::;     '*´  ;',·':::;‘    ]],
        -- [[ ,' ,'::::\·²*'´¨¯':,'\:;     \·-;::\:::::'`:·-.,';          ,'   ,.'\::;·´           \*´\:::;‘    \´¨\::;          \¨\::::;         ]],
        -- [[ \`¨\:::/          \::\'      \::\:;'` ·:;:::::\::\'        \`*´\:::\;     ‘         '\::\:;'      '\::\;            \:\;·'          ]],
        -- [[  '\::\;'            '\;'  '     '·-·'       `' · -':::''        '\:::\;'                   `*´‘         '´¨               ¨'        ]],
        -- [[ `¨'                                                       `*´‘                                                                      ]],
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
        button(
          'Directory',
          'r',
          '  Restore session',
          "<Cmd>lua require('persistence').load({ last = true })<CR>"
        ),
        button(
          'Todo',
          's',
          '󰋇  Pick a session',
          "<Cmd>lua require('persistence').select()<CR>"
        ),
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
      dashboard.opts.layout = {
        { type = 'padding', val = 4 },
        { type = 'group', val = neovim_header() },
        { type = 'padding', val = 1 },
        installed_plugins,
        { type = 'padding', val = 2 },
        dashboard.section.buttons,
        dashboard.section.footer,
        { type = 'padding', val = 2 },
        version,
      }
      dashboard.opts.margin = 5
      return dashboard
    end,
    config = function(_, dashboard)
      require('alpha').setup(dashboard.opts)

      ar.augroup('AlphaStats', {
        event = 'User',
        once = true,
        pattern = 'LazyVimStarted',
        command = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.opts.layout[4] = {
            type = 'text',
            val = fmt(
              ' %s plugins loaded in %s',
              stats.loaded .. ' of ' .. stats.count,
              ms .. 'ms'
            ),
            opts = { position = 'center', hl = 'GitSignsAdd' },
          }
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
  {
    'startup-nvim/startup.nvim',
    cond = minimal and niceties,
    lazy = false,
    opts = function()
      local header = {
        [[                   ▂▂▂▂▂▂                      ▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂                      ▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂                      ▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂                      ▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂                   ]],
        [[                                                                        ]],
        [[                                                                        ]],
        [[▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂         ▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂         ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂]],
        [[▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂         ▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂         ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂]],
        [[▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂]],
        [[          ▂▂▂▂▂    ▂▂▂▂▂▂    ▂▂▂▂▂    ▂▂▂▂▂    ▂▂▂▂▂▂    ▂▂▂▂▂          ]],
        [[          ▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂          ]],
        [[                   ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂                   ]],
        [[                                                                        ]],
        [[                                                                        ]],
        [[          ▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂          ]],
        [[          ▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂          ]],
        [[▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂]],
        [[▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂    ▂▂▂▂▂    ▂▂▂▂▂    ▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂]],
        [[▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂]],
        [[                        ▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂                        ]],
        [[                        ▂▂▂▂▂▂▂▂▂▂    ▂▂▂▂▂▂▂▂▂▂                        ]],
        [[                                                                        ]],
        [[                                                                        ]],
        [[                   ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂▂▂▂▂              ▂▂▂▂▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂                      ▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂                      ▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂                      ▂▂▂▂▂▂                   ]],
        [[                   ▂▂▂▂▂▂                      ▂▂▂▂▂▂                   ]],
      }

      return {
        header = {
          type = 'text',
          align = 'center',
          fold_section = false,
          title = 'Header',
          margin = 3,
          content = header,
          highlight = '@variable',
          oldfiles_amount = 0,
        },
        clock = {
          type = 'text',
          content = function()
            local time = '' .. os.date('%H:%M')
            local date = '' .. os.date('%Y-%m-%d')
            return { date, time }
          end,
          oldfiles_directory = false,
          align = 'center',
          fold_section = false,
          title = '',
          margin = 3,
          highlight = '@variable',
        },
        statistics = {
          type = 'text',
          content = function()
            local v = vim.version()
            local version = fmt(
              'Neovim v%d.%d.%d %s',
              v.major,
              v.minor,
              v.patch,
              v.prerelease and '(nightly)' or ''
            )
            return { version }
          end,
          oldfiles_directory = false,
          align = 'center',
          fold_section = false,
          title = '',
          margin = 3,
          highlight = '@comment',
        },
        parts = { 'header', 'clock', 'statistics' },
      }
    end,
    config = function(_, opts) require('startup').setup(opts) end,
  },
  {
    'letieu/btw.nvim',
    cond = minimal and not niceties,
    lazy = false,
    config = function() require('btw').setup() end,
  },
}
