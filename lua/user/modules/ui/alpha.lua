local M = { 'goolord/alpha-nvim', lazy = false }

function M.config()
  local alpha = require('alpha')
  local dashboard = require('alpha.themes.dashboard')
  local fortune = require('alpha.fortune')
  local f = string.format

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

  local stats = require('lazy').stats()

  local installed_plugins = {
    type = 'text',
    val = f(' %d plugins installed', stats.count),
    opts = { position = 'center', hl = 'NonText' },
  }

  local v = vim.version()
  local version = {
    type = 'text',
    val = f('Neovim v%d.%d.%d %s', v.major, v.minor, v.patch, v.prerelease and '(nightly)' or ''),
    opts = { position = 'center', hl = 'NonText' },
  }

  dashboard.section.buttons.val = {
    button('Directory', 's', '  Restore session', '<cmd>lua require("persistence").load()<CR>'),
    button('Type', 'r', '  Recently used', ':Telescope oldfiles<CR>'),
    button('String', 'f', '  Find file', ':Telescope find_files<CR>'),
    button('Define', 'w', '  Find text', ':Telescope live_grep<CR>'),
    button('Keyword', 'n', '  New file', ':ene | startinsert<CR>'),
    button('Ignore', 'l', '鈴 Lazy', ':Lazy<CR>'),
    button('ErrorMsg', 'q', '  Quit', ':qa<CR>'),
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

return M
