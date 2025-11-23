local fn, api = vim.fn, vim.api
local bo = vim.bo
local decor = ar.ui.decorations
local minimal = ar.plugins.minimal
local variant = ar_config.ui.statusline.variant

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
          local theming = require('ar.theming')
          local utils = require('heirline.utils')
          utils.on_colorscheme(theming.get_statusline_palette(arg.match))
        end,
      })
    end,
    config = function(_, opts)
      local conditions = require('heirline.conditions')

      if ar_config.ui.statusline.enable and variant == 'heirline' then
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

      if ar_config.ui.statuscolumn.enable and variant == 'heirline' then
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
