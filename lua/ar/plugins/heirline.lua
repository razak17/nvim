local fn, api = vim.fn, vim.api
local bo = vim.bo
local decor = ar.ui.decorations
local minimal = ar.plugins.minimal

local buftypes = { 'nofile', 'prompt', 'help', 'quickfix' }

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
  -- TODO: Overriding statusline highlight twice (also in colors overrides)
  hl.plugin('heirline', {
    theme = {
      ['default'] = {
        {
          StatusLine = {
            bg = { from = 'StatusLine', alter = -0.85 },
            fg = { from = 'Normal' },
          },
        },
      },
    },
  })
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
  }
  if ar_config.colorscheme == 'default' then
    return vim.tbl_deep_extend('force', P, {
      blue = ar.highlight.get('DiagnosticInfo', 'fg'),
      dark_orange = ar.highlight.get('DiagnosticWarn', 'fg'),
      error_red = ar.highlight.get('ExtraWhitespace', 'fg'),
      pale_red = ar.highlight.get('DiagnosticError', 'fg'),
      pale_blue = ar.highlight.get('DiagnosticInfo', 'fg'),
      forest_green = ar.highlight.get('DiffAdd', 'bg'),
    })
  end
  if ar_config.colorscheme == 'onedark' then P = require('onedark.palette') end
  return P
end

ar.augroup('Heirline', {
  event = 'ColorScheme',
  command = function()
    if not ar.is_available('heirline.nvim') then return end
    local utils = require('heirline.utils')
    utils.on_colorscheme(setup_colors)
  end,
})

return {
  {
    'rebelot/heirline.nvim',
    event = 'BufWinEnter',
    cond = not minimal,
    config = function(_, opts)
      local conditions = require('heirline.conditions')
      local statusline = require('ar.statusline')

      opts.colors = setup_colors
      opts.statusline = vim.tbl_deep_extend('force', opts.statusline or {}, {
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
      opts.statuscolumn =
        vim.tbl_deep_extend('force', opts.statuscolumn or {}, {
          condition = function()
            if
              not ar_config.ui.statuscolumn.enable
              or ar_config.ui.statuscolumn.variant ~= 'plugin'
            then
              return false
            end
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

      require('heirline').setup(opts)
      ar.augroup('HeirlineGitRemote', {
        event = { 'VimEnter' },
        command = function()
          local timer = vim.uv.new_timer()
          ---@diagnostic disable-next-line: need-check-nil
          timer:start(0, 120000, function() statusline.git_remote_sync() end)
        end,
      }, {
        event = { 'User' },
        pattern = { 'Neogit*' },
        command = function()
          local timer = vim.uv.new_timer()
          ---@diagnostic disable-next-line: need-check-nil
          timer:start(0, 120000, function() statusline.git_remote_sync() end)
        end,
      })
    end,
  },
}
