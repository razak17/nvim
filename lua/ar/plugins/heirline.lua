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
  '^TelescopePrompt$',
  '^undotree$',
}

local function setup_colors()
  local hl = ar.highlight
  local P = {
    bg_dark = hl.get('StatusLine', 'bg'),
    fg = hl.get('Normal', 'fg'),
    blue = hl.get('DiagnosticInfo', 'bg'),
    dark_orange = hl.get('DiagnosticWarn', 'bg'),
    error_red = hl.get('NvimInternalError', 'bg'),
    pale_red = ar.highlight.get('Error', 'fg'),
    pale_blue = hl.get('DiagnosticInfo', 'bg'),
    comment = hl.get('Comment', 'fg'),
    forest_green = hl.get('DiffAdd', 'fg'),
    lightgreen = hl.get('DiagnosticVirtualTextHint', 'bg'),
  }
  if vim.g.colors_name == 'default' then
    return vim.tbl_deep_extend('force', P, {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.3),
      fg = hl.get('Normal', 'fg'),
      blue = hl.get('DiagnosticInfo', 'fg'),
      dark_orange = hl.get('DiagnosticWarn', 'fg'),
      error_red = hl.get('ExtraWhitespace', 'fg'),
      pale_red = hl.get('DiagnosticError', 'fg'),
      pale_blue = hl.get('DiagnosticInfo', 'fg'),
      forest_green = hl.get('DiffAdd', 'bg'),
      lightgreen = hl.get('DiagnosticVirtualTextHint', 'fg'),
    })
  end
  if vim.g.colors_name == 'peachpuff' then
    return vim.tbl_deep_extend('force', P, {
      bg_dark = hl.get('CursorLine', 'bg'),
      fg = hl.get('Comment', 'fg'),
      blue = hl.tint(hl.get('Visual', 'bg'), -0.4),
      yellowgreen = hl.get('String', 'fg'),
      dark_orange = hl.tint(hl.get('WarningMsg', 'fg'), -0.2),
      error_red = hl.tint(hl.get('Error', 'fg'), -0.4),
      pale_red = hl.tint(hl.get('Error', 'fg'), 0.2),
      pale_blue = hl.tint(hl.get('DiagnosticInfo', 'fg'), -0.2),
      forest_green = hl.tint(hl.get('DiffAdd', 'bg'), -0.3),
      lightgreen = hl.tint(hl.get('DiagnosticVirtualTextHint', 'fg'), -0.2),
      orange = hl.get('Constant', 'fg'),
    })
  end
  if vim.g.colors_name == 'retrobox' then
    return vim.tbl_deep_extend('force', P, {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.2),
      blue = hl.get('DiagnosticInfo', 'fg'),
      dark_orange = hl.get('WarningMsg', 'fg'),
    })
  end
  if vim.g.colors_name == 'onedark' then P = require('onedark.palette') end
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
        command = function()
          if not ar.has('heirline.nvim') then return end
          local utils = require('heirline.utils')
          utils.on_colorscheme(setup_colors)
        end,
      })
    end,
    config = function(_, opts)
      local conditions = require('heirline.conditions')
      local stl = require('ar.statusline')

      opts.statusline = vim.tbl_deep_extend('force', opts.statusline or {}, {
        static = {
          filetypes = filetypes,
          force_inactive_filetypes = force_inactive_filetypes,
        },
        -- condition = function()
        --   local win = api.nvim_get_current_win()
        --   local buf = api.nvim_win_get_buf(win)
        --   local decs = decor.get({
        --     ft = bo[buf].ft,
        --     fname = fn.bufname(buf),
        --     setting = 'statusline',
        --   })
        --   if not decs or ar.falsy(decs) then
        --     return not conditions.buffer_matches({
        --       buftype = buftypes,
        --       filetype = force_inactive_filetypes,
        --     })
        --   end
        --   return decs.ft == true or decs.fname == true
        -- end,
      })

      if
        ar_config.ui.statuscolumn.enable
        and ar_config.ui.statuscolumn.variant == 'plugin'
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

      ar.augroup('HeirlineGitRemote', {
        event = { 'VimEnter' },
        command = function()
          if not ar.is_git_repo() then return end
          -- ar.set_timeout(stl.git_remote_sync, 0, 120000)
          -- vim.schedule(function() stl.git_remote_sync() end)
          vim.schedule(function() stl.update_ahead_behind(true) end)
        end,
      }, {
        event = { 'User' },
        pattern = { 'Neogit*' },
        command = function()
          if not ar.is_git_repo() then return end
          -- ar.set_timeout(stl.git_remote_sync, 0, 120000)
          -- vim.schedule(function() stl.git_remote_sync() end)
          vim.schedule(function() stl.update_ahead_behind(true) end)
        end,
      })
    end,
  },
}
