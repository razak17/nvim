return function()
  if not rvim.plugin_installed('alpha-nvim') then return end
  local alpha = require('alpha')
  local dashboard = require('alpha.themes.dashboard')
  local fortune = require('alpha.fortune')
  local hl = require('user.utils.highlights')
  local f = string.format

  local button = function(h, ...)
    local btn = dashboard.button(...)
    local details = select(2, ...)
    local icon = details:match('[^%w%s]+') -- match non alphanumeric or space characters
    btn.opts.hl = { { h, 0, #icon + 1 } } -- add one space padding
    btn.opts.hl_shortcut = 'Title'
    return btn
  end

  hl.plugin('alpha', {
    { StartLogo1 = { fg = '#1C506B' } },
    { StartLogo2 = { fg = '#1D5D68' } },
    { StartLogo3 = { fg = '#1E6965' } },
    { StartLogo4 = { fg = '#1F7562' } },
    { StartLogo5 = { fg = '#21825F' } },
    { StartLogo6 = { fg = '#228E5C' } },
    { StartLogo7 = { fg = '#239B59' } },
    { StartLogo8 = { fg = '#24A755' } },
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
  }

  -- Make the header a bit more fun with some color!
  local function neovim_header()
    return rvim.map(
      function(chars, i)
        return {
          type = 'text',
          val = chars,
          opts = {
            hl = 'StartLogo' .. i,
            shrink_margin = false,
            position = 'center',
          },
        }
      end,
      header
    )
  end

  local installed_plugins = {
    type = 'text',
    val = f(' %d plugins installed', #rvim.list_installed_plugins()),
    opts = { position = 'center', hl = 'NonText' },
  }

  dashboard.section.buttons.val = {
    button('Directory', 'r', '  Restore last session', '<Cmd>RestoreSession<CR>'),
    button('Todo', 's', '  Pick a session', '<Cmd>Autosession search<CR>'),
    button('Label', 'o', '  Recent Projects', ':Telescope oldfiles<CR>'),
    button('Title', 'f', '  Find file', ':Telescope find_files<CR>'),
    button('String', 'g', '  Find word', ':Telescope live_grep<CR>'),
    button('String', 'e', '  New file', ':ene | startinsert <CR>'),
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
    },
    opts = { margin = 5 },
  })

  rvim.augroup('AlphaSettings', {
    {
      event = { 'User ' },
      pattern = { 'AlphaReady' },
      command = function(args)
        vim.opt_local.foldenable = false
        vim.opt_local.colorcolumn = ''
        vim.o.laststatus = 0
        rvim.nnoremap('q', '<Cmd>Alpha<CR>', { buffer = args.buf, nowait = true })

        vim.api.nvim_create_autocmd('BufUnload', {
          buffer = args.buf,
          callback = function() vim.o.laststatus = 3 end,
        })
      end,
    },
  })
end
