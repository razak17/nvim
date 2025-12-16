local fn, v, api = vim.fn, vim.v, vim.api

local minimal = ar.plugins.minimal
local sep = ar.ui.icons.separators

return {
  desc = 'heirline statuscolumn',
  recommended = true,
  'rebelot/heirline.nvim',
  opts = function(_, opts)
    local cond = ar.config.ui.statuscolumn.enable
      and ar.config.ui.statuscolumn.variant == 'heirline'

    if not cond or minimal then return opts end

    local conditions = require('heirline.conditions')
    local is_git_repo = conditions.is_git_repo
    local align = { provider = '%=' }

    local statuscol = require('ar.statuscolumn')
    local space = statuscol.space
    local spacer = { provider = space(), hl = 'HeirlineStatusColumn' }
    local shade = sep.light_shade_block

    local inactive_statuscolumn = {
      hl = { bg = 'NONE', fg = 'fg' },
      condition = function(self)
        return conditions.buffer_matches({
          filetype = self.force_inactive_filetypes,
        }) or vim.bo.ft == ''
      end,
      { provider = '' },
      align,
    }

    local statuscolumn = {
      init = function(self)
        local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
        local win = api.nvim_get_current_win()
        local buf = api.nvim_win_get_buf(win)
        local line_count = api.nvim_buf_line_count(buf)

        self.ln = statuscol.nr(win, lnum, relnum, virtnum, line_count)
        self.left, self.g_sns = statuscol.get_left(buf, lnum)
        self.no = vim.wo[win].signcolumn == 'no'
      end,
      -- Signs
      {
        provider = function(self) return self.no and '' or self.left end,
        on_click = {
          name = 'sign_click',
          callback = function(self, ...)
            if self.handlers.signs then
              self.handlers.signs(self.click_args(self, ...))
            end
          end,
        },
      },
      align,
      spacer,
      -- Line numbers
      {
        provider = function(self) return self.ln end,
        on_click = {
          name = 'line_number_click',
          callback = function(self, ...)
            if self.handlers.line_number then
              self.handlers.line_number(self.click_args(self, ...))
            end
          end,
        },
      },
      spacer,
      -- Git signs
      {
        {
          condition = function() return not is_git_repo() or v.virtnum ~= 0 end,
          provider = space(),
          hl = 'HeirlineStatusColumn',
        },
        {
          condition = function() return is_git_repo() and v.virtnum == 0 end,
          init = function(self)
            if #self.g_sns == 0 then
              self.gitsign = nil
            else
              self.gitsign = unpack(self.g_sns)
            end
            self.has_gitsign = self.gitsign ~= nil
          end,
          provider = function(self)
            if self.has_gitsign then return self.gitsign.text end
            return space()
          end,
          hl = function(self)
            if self.has_gitsign then return self.gitsign.texthl end
            return 'HeirlineStatusColumn'
          end,
          on_click = {
            name = 'gitsigns_click',
            callback = function(self, ...)
              if self.handlers.git_signs then
                self.handlers.git_signs(self.click_args(self, ...))
              end
            end,
          },
        },
      },
      -- Virtual lines
      {
        init = function(self)
          self.is_wrap = self.ln:gsub('^%s*(.-)%s*$', '%1') == ''
          self.is_shade = self.ln:gsub('^%s*(.-)%s*$', '%1') == shade
        end,
        provider = function(self)
          if self.is_shade then return '' end
          if not self.is_wrap then return sep.left_thin_block end
          return ''
        end,
        hl = 'IndentBlanklineChar',
      },
      -- Folds
      {
        condition = function() return v.virtnum == 0 end,
        init = function(self) self.fold = statuscol.get_fold(v.lnum) end,
        {
          provider = function(self) return self.fold.text end,
          hl = function(self) return self.fold.texthl end,
        },
        on_click = {
          name = 'fold_click',
          callback = function(self, ...)
            if self.handlers.fold then
              self.handlers.fold(self.click_args(self, ...))
            end
          end,
        },
        spacer,
      },
    }

    return vim.tbl_deep_extend('force', opts or {}, {
      statuscolumn = vim.tbl_deep_extend('force', opts.statuscolumn or {}, {
        fallthrough = false,
        static = {
          force_inactive_filetypes = {
            '^aerial$',
            '^alpha$',
            '^netrw$',
            '^oil$',
            '^undotree$',
          },
          click_args = function(self, minwid, clicks, button, mods)
            local args = {
              minwid = minwid,
              clicks = clicks,
              button = button,
              mods = mods,
              mousepos = fn.getmousepos(),
            }
            local sign =
              fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
            if sign == ' ' then
              sign = fn.screenstring(
                args.mousepos.screenrow,
                args.mousepos.screencol - 1
              )
            end
            args.sign = self.signs[sign]
            api.nvim_set_current_win(args.mousepos.winid)
            api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })

            return args
          end,
          handlers = {},
        },
        init = function(self)
          self.signs = {}

          self.handlers.signs = function(_)
            return vim.schedule(vim.diagnostic.open_float)
          end

          self.handlers.line_number = function(_)
            local dap_avail, dap = pcall(require, 'dap')
            if dap_avail then vim.schedule(dap.toggle_breakpoint) end
          end

          self.handlers.git_signs = function(_)
            local gitsigns_avail, gitsigns = pcall(require, 'gitsigns')
            if gitsigns_avail then vim.schedule(gitsigns.preview_hunk) end
          end

          self.handlers.fold = function(args)
            local lnum = args.mousepos.line
            if fn.foldlevel(lnum) <= fn.foldlevel(lnum - 1) then return end
            vim.cmd.execute(
              "'"
                .. lnum
                .. 'fold'
                .. (fn.foldclosed(lnum) == -1 and 'close' or 'open')
                .. "'"
            )
          end
        end,
        inactive_statuscolumn,
        statuscolumn,
      }),
    })
  end,
}
