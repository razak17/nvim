local fn, api = vim.fn, vim.api
local bo = vim.bo
local decor = ar.ui.decorations
local minimal = ar.plugins.minimal

local buftypes = { 'nofile', 'prompt', 'help', 'quickfix' }

local filetypes = {
  '^git.*',
  'fugitive',
  'alpha',
  'DiffviewFiles',
  'help',
  'lazy',
  '^neo--tree$',
  '^neotest--summary$',
  '^neo--tree--popup$',
  '^NvimTree$',
  'snacks_dashboard',
  'snacks_picker_*',
  'scheme_switcher',
  '^TelescopePrompt$',
  '^toggleterm$',
  'FloatermSidebar',
  'VoltWindow',
}

-- Filetypes which force the statusline to be inactive
local force_inactive_filetypes = {
  '^aerial$',
  '^alpha$',
  '^chatgpt$',
  '^DressingInput$',
  '^frecency$',
  '^lazy$',
  '^lazyterm$',
  '^netrw$',
  '^oil$',
  '^undotree$',
}

local function setup_colors(colorscheme)
  local hl = ar.highlight
  local P = {
    bg_dark = hl.get('StatusLine', 'bg'),
    fg = hl.get('Normal', 'fg'),
    blue = hl.get('Directory', 'fg'),
    dark_orange = hl.get('WarningMsg', 'fg'),
    error_red = hl.get('NvimInternalError', 'bg'),
    pale_red = ar.highlight.get('Error', 'fg'),
    pale_blue = hl.get('DiagnosticInfo', 'bg'),
    comment = hl.get('Comment', 'fg'),
    forest_green = hl.get('DiffAdd', 'fg'),
    lightgreen = hl.get('DiagnosticVirtualTextHint', 'bg'),
  }
  local overrides = {
    default = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.3),
      fg = hl.tint(hl.get('Comment', 'fg'), 0.55),
      pale_red = hl.get('DiagnosticError', 'fg'),
      pale_blue = hl.get('DiagnosticInfo', 'fg'),
      forest_green = hl.get('DiffAdd', 'bg'),
      lightgreen = hl.get('DiagnosticVirtualTextHint', 'fg'),
    },
    habamax = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.2),
      fg = hl.tint(hl.get('Comment', 'fg'), 0.55),
    },
    peachpuff = {
      bg_dark = hl.get('CursorLine', 'bg'),
      fg = hl.get('Comment', 'fg'),
      yellowgreen = hl.get('String', 'fg'),
      dark_orange = hl.tint(hl.get('WarningMsg', 'fg'), -0.2),
      error_red = hl.tint(hl.get('Error', 'fg'), -0.4),
      pale_red = hl.tint(hl.get('Error', 'fg'), 0.2),
      pale_blue = hl.tint(hl.get('DiagnosticInfo', 'fg'), -0.2),
      forest_green = hl.tint(hl.get('DiffAdd', 'bg'), -0.3),
      lightgreen = hl.tint(hl.get('DiagnosticVirtualTextHint', 'fg'), -0.2),
      orange = hl.get('Constant', 'fg'),
    },
    retrobox = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.2),
      blue = hl.tint(hl.get('Changed', 'fg'), 0.2),
    },
    slate = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.1),
      fg = hl.tint(hl.get('Comment', 'fg'), 0.8),
      blue = hl.get('DiffChange', 'bg'),
    },
    vim = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.55),
    },
    wildcharm = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.6),
    },
    afterglow = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
    },
    ashen = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    bamboo = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
    },
    cyberdream = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.3),
    },
    darcubox = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
      dark_orange = hl.get('Label', 'fg'),
    },
    darkmatter = {
      dark_orange = hl.get('Label', 'fg'),
      error_red = hl.get('TSType', 'fg'),
      comment = hl.tint(hl.get('LineNr', 'fg'), -0.15),
    },
    darkvoid = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    ['doom-one'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.05),
    },
    eldritch = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
    },
    everforest = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
      blue = hl.get('DiagnosticInfo', 'fg'),
    },
    evergarden = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
    },
    ferriouscolor = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
      blue = hl.get('Changed', 'fg'),
    },
    glowbeam = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
    },
    ['github_dark'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.2),
    },
    gruvbox = {
      bg_dark = hl.tint(hl.get('Normal', 'bg'), 0.25),
      blue = hl.get('Changed', 'fg'),
      forest_green = hl.tint(hl.get('DiffAdd', 'bg'), -0.3),
      lightgreen = hl.tint(hl.get('DiagnosticVirtualTextHint', 'fg'), -0.2),
    },
    horizon = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
      blue = hl.get('Changed', 'fg'),
    },
    iceclimber = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.25),
    },
    jellybeans = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    kanagawa = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    lavish = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.25),
    },
    ['mono-jade'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
    },
    makurai_dark = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
    },
    naysayer = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
    },
    nightfox = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    ['night-owl'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
    },
    ['no-clown-fiesta'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.2),
    },
    ['oh-lucy'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
    },
    poimandres = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
    },
    rasmus = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
      comment = hl.tint(hl.get('Comment', 'fg'), 0.15),
    },
    ronny = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
      blue = hl.get('Changed', 'fg'),
    },
    ['rose-pine'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.05),
    },
    serenity = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
      blue = hl.get('Define', 'fg'),
    },
    shadow = {
      bg_dark = hl.tint(hl.get('NormalFloat', 'bg'), 0.25),
      comment = hl.tint(hl.get('Comment', 'fg'), 0.45),
    },
    sunbather = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
    },
    tokyonight = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.1),
    },
    wildberries = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
      blue = hl.get('DiagnosticInfo', 'fg'),
      comment = hl.tint(hl.get('LineNr', 'fg'), -0.15),
    },
    zenbones = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.1),
      blue = hl.get('DiagnosticInfo', 'fg'),
    },
    zenburn = {
      bg_dark = hl.tint(hl.get('Normal', 'bg'), 0.25),
      dark_orange = hl.get('Function', 'fg'),
      pale_blue = hl.tint(hl.get('DiagnosticInfo', 'fg'), -0.2),
      forest_green = hl.tint(hl.get('DiffAdd', 'bg'), -0.3),
      lightgreen = hl.tint(hl.get('DiagnosticVirtualTextHint', 'fg'), -0.2),
    },
  }
  if overrides[colorscheme] then
    return vim.tbl_deep_extend('force', P, overrides[colorscheme])
  end
  if colorscheme == 'onedark' then P = require('onedark.palette') end
  return P
end

return {
  {
    'rebelot/heirline.nvim',
    event = 'BufWinEnter',
    cond = function() return ar.get_plugin_cond('heirline.nvim', not minimal) end,
    init = function()
      ar.augroup('Heirline', {
        event = 'ColorScheme',
        command = function(arg)
          if not ar.has('heirline.nvim') then return end
          local utils = require('heirline.utils')
          utils.on_colorscheme(setup_colors(arg.match))
        end,
      })
    end,
    config = function(_, opts)
      local conditions = require('heirline.conditions')

      if
        ar_config.ui.statusline.enable
        and ar_config.ui.statusline.variant == 'heirline'
      then
        opts.statusline = vim.tbl_deep_extend('force', opts.statusline or {}, {
          static = {
            filetypes = filetypes,
            force_inactive_filetypes = force_inactive_filetypes,
          },
          condition = function()
            local win = api.nvim_get_current_win()
            local buf = api.nvim_win_get_buf(win)
            local decs = decor.get({
              ft = bo[buf].ft,
              fname = fn.bufname(buf),
              setting = 'statusline',
            })
            if not decs or ar.falsy(decs) then
              return not conditions.buffer_matches({
                buftype = buftypes,
                filetype = force_inactive_filetypes,
              })
            end
            return decs.ft == true or decs.fname == true
          end,
        })
      end

      if
        ar_config.ui.statuscolumn.enable
        and ar_config.ui.statuscolumn.variant == 'heirline'
      then
        opts.statuscolumn =
          vim.tbl_deep_extend('force', opts.statuscolumn or {}, {
            condition = function()
              local win = api.nvim_get_current_win()
              local buf = api.nvim_win_get_buf(win)
              local decs = decor.get({
                ft = bo[buf].ft,
                fname = fn.bufname(buf),
                setting = 'statuscolumn',
              })
              if not decs or ar.falsy(decs) then
                return not conditions.buffer_matches({
                  buftype = buftypes,
                  filetype = force_inactive_filetypes,
                })
              end
              return decs.ft == true or decs.fname == true
            end,
          })
      end

      require('heirline').setup(opts)
    end,
  },
}
